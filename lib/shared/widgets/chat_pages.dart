import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/di/service_locator.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class ChatThread {
  const ChatThread({
    this.userId,
    required this.name,
    required this.role,
    required this.lastMessage,
    required this.lastTime,
    this.unread = 0,
    this.isBroadcast = false,
  });

  /// Id người đối thoại từ backend (null cho mock data tĩnh).
  final String? userId;
  final String name;
  final String role;
  final String lastMessage;
  final String lastTime;
  final int unread;
  final bool isBroadcast;

  /// Map 1 thread từ REST backend sang model mà thread-row UI đang render.
  /// API: {userId, name, lastMessage, lastTime(ISO), unread(int)}
  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      userId: json['userId']?.toString(),
      name: (json['name'] ?? '').toString(),
      role: '',
      lastMessage: (json['lastMessage'] ?? '').toString(),
      lastTime: _formatTime(json['lastTime']),
      unread: (json['unread'] is num) ? (json['unread'] as num).toInt() : 0,
    );
  }

  factory ChatThread.fromContact(Map<String, dynamic> json) => ChatThread(
        userId: json['id']?.toString(),
        name: (json['fullName'] ?? '').toString(),
        role: (json['role'] ?? '').toString(),
        lastMessage: 'Bắt đầu hội thoại',
        lastTime: '',
      );

  static String _formatTime(Object? raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return raw.toString();
    return DateFormat('dd/MM HH:mm').format(dt.toLocal());
  }
}

class ChatListPage extends StatefulWidget {
  const ChatListPage({
    super.key,
    required this.accent,
    this.threads,
    this.allowBroadcast = false,
  });

  final Color accent;

  /// Giữ lại cho tương thích với caller cũ (vd: `threads: _parentThreads`).
  /// Widget BỎ QUA giá trị này và luôn lấy dữ liệu LIVE từ API.
  final List<ChatThread>? threads;
  final bool allowBroadcast;

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late final Future<List<List<Map<String, dynamic>>>> _future = Future.wait([
    sl<ApiService>().chatThreads(),
    sl<ApiService>().chatContacts(),
  ]);

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    return FutureBuilder<List<List<Map<String, dynamic>>>>(
      future: _future,
      builder: (context, snap) {
        final loading = snap.connectionState != ConnectionState.done;
        final threadRows =
            snap.data == null ? const <Map<String, dynamic>>[] : snap.data![0];
        final contactRows =
            snap.data == null ? const <Map<String, dynamic>>[] : snap.data![1];
        final existing = threadRows.map(ChatThread.fromJson).toList();
        final threads = contactRows.map((contact) {
          final id = contact['id']?.toString();
          final matched = existing.where((thread) => thread.userId == id);
          return matched.isEmpty
              ? ChatThread.fromContact(contact)
              : matched.first;
        }).toList();
        final dms = threads.where((t) => !t.isBroadcast).toList();
        final broadcasts = threads.where((t) => t.isBroadcast).toList();
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Tin nhắn'),
              backgroundColor: accent,
              bottom: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'Cá nhân (${dms.length})'),
                  Tab(text: 'Lớp (${broadcasts.length})'),
                ],
              ),
            ),
            floatingActionButton: widget.allowBroadcast
                ? FloatingActionButton.extended(
                    onPressed: _showBroadcastSheet,
                    backgroundColor: accent,
                    icon: const Icon(Icons.campaign_rounded),
                    label: const Text('Broadcast'),
                  )
                : null,
            body: loading
                ? const Center(child: CircularProgressIndicator())
                : snap.hasError
                    ? Center(
                        child: Text('Lỗi: ${snap.error}',
                            style: const TextStyle(
                                color: AppColors.textSecondary)))
                    : TabBarView(
                        children: [
                          _ThreadList(threads: dms, accent: accent),
                          _ThreadList(threads: broadcasts, accent: accent),
                        ],
                      ),
          ),
        );
      },
    );
  }

  Future<void> _showBroadcastSheet() async {
    final messenger = ScaffoldMessenger.of(context);
    List<Map<String, dynamic>> classes;
    try {
      classes = await sl<ApiService>().teachingClasses();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
          SnackBar(content: Text('Không tải được lớp phụ trách: $e')));
      return;
    }
    if (!mounted || classes.isEmpty) return;
    final ctrl = TextEditingController();
    String target = classes.first['id'].toString();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Broadcast tới lớp',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: target,
                decoration:
                    const InputDecoration(labelText: 'Lớp nhận', isDense: true),
                items: classes
                    .map((c) => DropdownMenuItem(
                        value: c['id'].toString(),
                        child: Text(c['code'].toString())))
                    .toList(),
                onChanged: (v) => setState(() => target = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    if (ctrl.text.trim().isEmpty) return;
                    try {
                      await sl<ApiService>().broadcastToClass(
                          target, 'Thông báo từ giáo viên', ctrl.text.trim());
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      messenger.showSnackBar(const SnackBar(
                        content: Text('Đã gửi thông báo tới lớp'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ));
                    } catch (e) {
                      if (!ctx.mounted) return;
                      messenger.showSnackBar(
                          SnackBar(content: Text('Không thể gửi: $e')));
                    }
                  },
                  style: FilledButton.styleFrom(backgroundColor: widget.accent),
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Gửi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThreadList extends StatelessWidget {
  const _ThreadList({required this.threads, required this.accent});
  final List<ChatThread> threads;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (threads.isEmpty) {
      return const Center(
          child: Text('Không có cuộc trò chuyện',
              style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.separated(
      itemCount: threads.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (_, i) {
        final t = threads[i];
        return ListTile(
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: accent.withValues(alpha: 0.14),
            child: Icon(
              t.isBroadcast ? Icons.campaign_rounded : Icons.person_rounded,
              color: accent,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(t.name,
                    style: TextStyle(
                        fontWeight:
                            t.unread > 0 ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14)),
              ),
              Text(t.lastTime,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  t.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: t.unread > 0
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight:
                        t.unread > 0 ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              if (t.unread > 0)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${t.unread}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          onTap: () {
            final userId = t.userId;
            if (userId != null && userId.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _ChatThreadPage(
                    withUserId: userId,
                    title: t.name,
                    subtitle: t.role,
                    accent: accent,
                  ),
                ),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatRoomPage(
                    title: t.name,
                    subtitle: t.role,
                    accent: accent,
                    isBroadcast: t.isBroadcast,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.fromMe,
    required this.time,
    this.senderName,
  });
  final String text;
  final bool fromMe;
  final String time;
  final String? senderName;
}

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accent,
    this.isBroadcast = false,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final bool isBroadcast;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _ctrl = TextEditingController();
  final List<ChatMessage> _messages = [
    const ChatMessage(
      text: 'Chào cô ạ, hôm nay con em vắng vì bị sốt nhẹ.',
      fromMe: true,
      time: '08:30',
    ),
    const ChatMessage(
      text: 'Vâng anh chị, em nắm rồi. Cô đã đánh dấu vắng có phép. '
          'Bài tập về nhà cô sẽ gửi qua app.',
      fromMe: false,
      time: '08:32',
      senderName: 'Trần Thị Hoa',
    ),
    const ChatMessage(
      text: 'Dạ vâng, em cảm ơn cô.',
      fromMe: true,
      time: '08:33',
    ),
    const ChatMessage(
      text: 'Tối nay cô có gửi bài về nhà chương 3 cho con, '
          'phụ huynh nhắc cháu làm trước khi đi học buổi sau nhé.',
      fromMe: false,
      time: '15:42',
      senderName: 'Trần Thị Hoa',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        fromMe: true,
        time: 'Vừa xong',
      ));
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 15)),
            Text(widget.subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: widget.accent,
        actions: [
          IconButton(icon: const Icon(Icons.phone_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                return _Bubble(
                    message: m,
                    accent: widget.accent,
                    showSender: widget.isBroadcast);
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                    top: BorderSide(color: AppColors.divider, width: 0.5)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded,
                        color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send_rounded, color: widget.accent),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.accent,
    required this.showSender,
  });
  final ChatMessage message;
  final Color accent;
  final bool showSender;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: message.fromMe ? accent : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(message.fromMe ? 14 : 4),
                bottomRight: Radius.circular(message.fromMe ? 4 : 14),
              ),
              border:
                  message.fromMe ? null : Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: message.fromMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (showSender && !message.fromMe && message.senderName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      message.senderName!,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: accent),
                    ),
                  ),
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        message.fromMe ? Colors.white : AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.time,
                  style: TextStyle(
                    fontSize: 10,
                    color: message.fromMe
                        ? Colors.white70
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Trang hội thoại LIVE: nạp tin nhắn từ `chatMessages(withUserId)`,
/// gửi qua `sendChat(withUserId, body)` rồi tải lại danh sách.
class _ChatThreadPage extends StatefulWidget {
  const _ChatThreadPage({
    required this.withUserId,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String withUserId;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  State<_ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<_ChatThreadPage> {
  final _ctrl = TextEditingController();
  late Future<List<Map<String, dynamic>>> _future =
      sl<ApiService>().chatMessages(widget.withUserId);
  bool _sending = false;

  String get _myId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.id : '';
  }

  void _reload() {
    setState(() {
      _future = sl<ApiService>().chatMessages(widget.withUserId);
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      await sl<ApiService>().sendChat(widget.withUserId, text);
      if (!mounted) return;
      _ctrl.clear();
      _reload();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gửi thất bại: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  ChatMessage _messageFromJson(Map<String, dynamic> m, String myId) {
    final senderId = (m['senderId'] ?? '').toString();
    final raw = m['createdAt'];
    String time = '';
    if (raw != null) {
      final dt = DateTime.tryParse(raw.toString());
      time = dt != null
          ? DateFormat('dd/MM HH:mm').format(dt.toLocal())
          : raw.toString();
    }
    return ChatMessage(
      text: (m['body'] ?? '').toString(),
      fromMe: senderId == myId,
      time: time,
      senderName: (m['senderName'] ?? '').toString(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myId = _myId;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 15)),
            if (widget.subtitle.isNotEmpty)
              Text(widget.subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: widget.accent,
        actions: [
          IconButton(icon: const Icon(Icons.phone_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Text('Lỗi: ${snap.error}',
                        style: const TextStyle(color: AppColors.textSecondary)),
                  );
                }
                final messages = (snap.data ?? [])
                    .map((m) => _messageFromJson(m, myId))
                    .toList();
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Chưa có tin nhắn',
                        style: TextStyle(color: AppColors.textSecondary)),
                  );
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) => _Bubble(
                    message: messages[i],
                    accent: widget.accent,
                    showSender: false,
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                    top: BorderSide(color: AppColors.divider, width: 0.5)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded,
                        color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send_rounded, color: widget.accent),
                    onPressed: _sending ? null : _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
