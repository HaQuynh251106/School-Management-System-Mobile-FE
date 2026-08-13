import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/di/service_locator.dart';
import '../../core/network/api_service.dart';
import '../../core/network/realtime_service.dart';
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

  /// Id người đối thoại từ Backend.
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

  /// Giữ lại để tương thích với caller cũ; dữ liệu hiển thị luôn tải từ API.
  final List<ChatThread>? threads;
  final bool allowBroadcast;

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late Future<List<List<Map<String, dynamic>>>> _future = _load();

  Future<List<List<Map<String, dynamic>>>> _load() => Future.wait([
        sl<ApiService>().chatThreads(),
        sl<ApiService>().chatContacts(),
        if (widget.allowBroadcast)
          sl<ApiService>().teacherAnnouncementScopes()
        else
          Future.value(<Map<String, dynamic>>[]),
      ]);

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final authState = context.watch<AuthBloc>().state;
    final viewerRole =
        authState is AuthAuthenticated ? authState.user.role : '';
    return FutureBuilder<List<List<Map<String, dynamic>>>>(
      future: _future,
      builder: (context, snap) {
        final loading = snap.connectionState != ConnectionState.done;
        final threadRows =
            snap.data == null ? const <Map<String, dynamic>>[] : snap.data![0];
        final contactRows =
            snap.data == null ? const <Map<String, dynamic>>[] : snap.data![1];
        final homeroomScopes = snap.data == null
            ? const <Map<String, dynamic>>[]
            : snap.data![2].where((item) => item['homeroom'] == true).toList();
        final canBroadcast = widget.allowBroadcast && homeroomScopes.isNotEmpty;
        final existing = threadRows.map(ChatThread.fromJson).toList();
        final threads = contactRows.map((contact) {
          final id = contact['id']?.toString();
          final matched = existing.where((thread) => thread.userId == id);
          return matched.isEmpty
              ? ChatThread.fromContact(contact)
              : ChatThread(
                  userId: matched.first.userId,
                  name: matched.first.name,
                  role: (contact['role'] ?? '').toString(),
                  lastMessage: matched.first.lastMessage,
                  lastTime: matched.first.lastTime,
                  unread: matched.first.unread,
                );
        }).toList();
        final dms = threads.where((t) => !t.isBroadcast).toList();
        final broadcasts = threads.where((t) => t.isBroadcast).toList();
        final threadList = RefreshIndicator(
          onRefresh: () async {
            final future = _load();
            setState(() => _future = future);
            await future;
          },
          child: _ThreadList(
            threads: dms,
            accent: accent,
            viewerRole: viewerRole,
            onConversationClosed: _reload,
          ),
        );
        return DefaultTabController(
          length: canBroadcast ? 2 : 1,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Tin nhắn'),
              backgroundColor: accent,
              bottom: canBroadcast
                  ? TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      indicatorColor: Colors.white,
                      tabs: [
                        Tab(text: 'Cá nhân (${dms.length})'),
                        Tab(text: 'Lớp (${broadcasts.length})'),
                      ],
                    )
                  : null,
            ),
            floatingActionButton: canBroadcast
                ? FloatingActionButton.extended(
                    onPressed: () => _showBroadcastSheet(homeroomScopes),
                    backgroundColor: accent,
                    icon: const Icon(Icons.campaign_rounded),
                    label: const Text('Gửi thông báo'),
                  )
                : null,
            body: loading
                ? const Center(child: CircularProgressIndicator())
                : snap.hasError
                    ? Center(
                        child: Text('Không thể tải danh sách trò chuyện.',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)))
                    : canBroadcast
                        ? TabBarView(
                            children: [
                              threadList,
                              _ThreadList(
                                threads: broadcasts,
                                accent: accent,
                                viewerRole: viewerRole,
                                onConversationClosed: _reload,
                              ),
                            ],
                          )
                        : threadList,
          ),
        );
      },
    );
  }

  Future<void> _showBroadcastSheet(List<Map<String, dynamic>> classes) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!mounted) return;
    if (classes.isEmpty) {
      messenger.showSnackBar(const SnackBar(
          content: Text(
              'Chỉ giáo viên chủ nhiệm mới có thể gửi thông báo tới học sinh và phụ huynh.')));
      return;
    }
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    titleCtrl.text = 'Thông báo tình hình lớp học';
    String target = classes.first['classId'].toString();
    const String category = 'STUDENT_STATUS';
    String recipientTarget = 'CLASS_ALL';
    String priority = 'NORMAL';
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final selectedScope = classes
              .firstWhere((item) => item['classId'].toString() == target);
          final studentCount =
              (selectedScope['studentCount'] as num?)?.toInt() ?? 0;
          final parentCount =
              (selectedScope['parentCount'] as num?)?.toInt() ?? 0;
          final recipientCount = recipientTarget == 'CLASS_STUDENTS'
              ? studentCount
              : recipientTarget == 'CLASS_PARENTS'
                  ? parentCount
                  : studentCount + parentCount;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gửi thông báo lớp học',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  'Điểm số và điểm danh được thông báo tự động khi lưu. Biểu mẫu này chỉ dùng để trao đổi tình hình lớp học.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: target,
                  decoration: const InputDecoration(
                      labelText: 'Lớp phụ trách', isDense: true),
                  items: classes
                      .map((item) => DropdownMenuItem(
                          value: item['classId'].toString(),
                          child: Text(
                              '${item['classCode']} · ${item['homeroom'] == true ? 'Chủ nhiệm' : 'Giảng dạy'}')))
                      .toList(),
                  onChanged: (value) => setState(() => target = value!),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.teacherAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: AppColors.teacherAccent),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Điểm mới và thay đổi trạng thái điểm danh được gửi ngay tới học sinh và phụ huynh, không gửi trùng khi dữ liệu không đổi.',
                          style: TextStyle(fontSize: 11, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: recipientTarget,
                  decoration: const InputDecoration(
                      labelText: 'Người nhận', isDense: true),
                  items: [
                    DropdownMenuItem(
                        value: 'CLASS_ALL',
                        child: Text(
                            'Học sinh & phụ huynh (${studentCount + parentCount})')),
                    DropdownMenuItem(
                        value: 'CLASS_STUDENTS',
                        child: Text('Học sinh ($studentCount)')),
                    DropdownMenuItem(
                        value: 'CLASS_PARENTS',
                        child: Text('Phụ huynh ($parentCount)')),
                  ],
                  onChanged: (value) =>
                      setState(() => recipientTarget = value!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration:
                      const InputDecoration(labelText: 'Mức độ', isDense: true),
                  items: const [
                    DropdownMenuItem(
                        value: 'NORMAL', child: Text('Thông thường')),
                    DropdownMenuItem(
                        value: 'IMPORTANT', child: Text('Quan trọng')),
                    DropdownMenuItem(value: 'URGENT', child: Text('Khẩn cấp')),
                  ],
                  onChanged: (value) => setState(() => priority = value!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  maxLength: 255,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: bodyCtrl,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 4000,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: recipientCount == 0
                        ? null
                        : () async {
                            if (titleCtrl.text.trim().isEmpty ||
                                bodyCtrl.text.trim().isEmpty) {
                              return;
                            }
                            try {
                              await sl<ApiService>().sendTeacherAnnouncement(
                                classId: target,
                                target: recipientTarget,
                                category: category,
                                priority: priority,
                                title: titleCtrl.text.trim(),
                                body: bodyCtrl.text.trim(),
                              );
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              messenger.showSnackBar(SnackBar(
                                content: Text(
                                    'Đã gửi thông báo tới $recipientCount người nhận'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ));
                            } catch (e) {
                              if (!ctx.mounted) return;
                              messenger.showSnackBar(const SnackBar(
                                  content: Text(
                                      'Không thể gửi thông báo. Vui lòng thử lại.')));
                            }
                          },
                    style:
                        FilledButton.styleFrom(backgroundColor: widget.accent),
                    icon: const Icon(Icons.send_rounded),
                    label: Text('Gửi tới $recipientCount người'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    titleCtrl.dispose();
    bodyCtrl.dispose();
  }
}

class _ThreadList extends StatelessWidget {
  const _ThreadList({
    required this.threads,
    required this.accent,
    required this.viewerRole,
    this.onConversationClosed,
  });
  final List<ChatThread> threads;
  final Color accent;
  final String viewerRole;
  final VoidCallback? onConversationClosed;

  @override
  Widget build(BuildContext context) {
    if (threads.isEmpty) {
      return Center(
          child: Text('Không có cuộc trò chuyện',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)));
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
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
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (t.role.isNotEmpty)
                      Text(_chatRoleLabel(t.role, viewerRole),
                          style: TextStyle(
                              fontSize: 10,
                              color: accent,
                              fontWeight: FontWeight.w600)),
                    Text(
                      t.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: t.unread > 0
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight:
                            t.unread > 0 ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
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
          onTap: () async {
            final userId = t.userId;
            if (userId != null && userId.isNotEmpty) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _ChatThreadPage(
                    withUserId: userId,
                    title: t.name,
                    subtitle: t.role,
                    accent: accent,
                  ),
                ),
              );
            }
            onConversationClosed?.call();
          },
        );
      },
    );
  }
}

String _chatRoleLabel(String role, String viewerRole) => switch (role) {
      'TEACHER' => 'Giáo viên phụ trách',
      'STUDENT' =>
        viewerRole == 'STUDENT' ? 'Bạn cùng lớp' : 'Học sinh lớp chủ nhiệm',
      'PARENT' => 'Phụ huynh lớp chủ nhiệm',
      'ADMIN' => 'Quản trị viên',
      _ => role,
    };

class ChatMessage {
  ChatMessage({
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
              color: message.fromMe
                  ? accent
                  : Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(message.fromMe ? 14 : 4),
                bottomRight: Radius.circular(message.fromMe ? 4 : 14),
              ),
              border: message.fromMe
                  ? null
                  : Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant),
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
                    color: message.fromMe
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
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
                        : Theme.of(context).colorScheme.onSurfaceVariant,
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

/// Trang hội thoại: nạp tin nhắn phân trang từ `chatMessages(withUserId)`,
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
  final _scrollCtrl = ScrollController();
  late Future<List<Map<String, dynamic>>> _future =
      sl<ApiService>().chatMessages(widget.withUserId);
  bool _sending = false;
  StreamSubscription<RealtimeEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    final realtime = sl<RealtimeService>()..connect();
    _subscription = realtime.events.where((event) {
      if (event.type != 'CHAT' && event.type != 'CHAT_READ') return false;
      final sender = (event.data['senderId'] ?? '').toString();
      final receiver = (event.data['receiverId'] ?? '').toString();
      return sender == widget.withUserId || receiver == widget.withUserId;
    }).listen((_) => _reload());
  }

  String get _myId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.id : '';
  }

  void _reload() {
    setState(() {
      _future = sl<ApiService>().chatMessages(widget.withUserId);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollCtrl.hasClients) return;
      _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
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
        const SnackBar(
          content: Text('Không thể gửi tin nhắn. Vui lòng thử lại.'),
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
    _subscription?.cancel();
    _ctrl.dispose();
    _scrollCtrl.dispose();
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
                    child: Text('Không thể tải tin nhắn.',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                  );
                }
                final messages = (snap.data ?? [])
                    .map((m) => _messageFromJson(m, myId))
                    .toList();
                if (messages.isEmpty) {
                  return Center(
                    child: Text('Chưa có tin nhắn',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                  );
                }
                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollCtrl,
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
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 2000,
                      buildCounter: (_,
                              {required currentLength,
                              required isFocused,
                              maxLength}) =>
                          null,
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
