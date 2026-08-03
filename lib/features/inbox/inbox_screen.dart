import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../../core/widgets/async_state_view.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabs;
  late Future<List<Map<String, dynamic>>> notifications;
  late Future<List<Map<String, dynamic>>> threads;

  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 2, vsync: this);
    reload();
  }

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  void reload() {
    final session = context.read<AppSession>();
    final api = session.api;
    notifications = api.list('/notifications');
    threads = api.list('/chat/threads');
    session.refreshUnreadCounts();
  }

  void refresh() => setState(reload);

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 10, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hộp thư',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      'Thông báo và trao đổi trong một nơi',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: refresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: tabs,
              indicator: BoxDecoration(
                color: widget.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant,
              dividerHeight: 0,
              tabs: const [
                Tab(text: 'Thông báo', icon: Icon(Icons.notifications_none)),
                Tab(text: 'Trao đổi', icon: Icon(Icons.chat_bubble_outline)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: tabs,
            children: [
              _NotificationsTab(
                future: notifications,
                accent: widget.accent,
                onRetry: refresh,
              ),
              _ThreadsTab(
                future: threads,
                accent: widget.accent,
                onRetry: refresh,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab({
    required this.future,
    required this.accent,
    required this.onRetry,
  });
  final Future<List<Map<String, dynamic>>> future;
  final Color accent;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) =>
      AsyncStateView<List<Map<String, dynamic>>>(
        future: future,
        onRetry: onRetry,
        builder: (context, items) {
          if (items.isEmpty) {
            return const EmptyState(
              title: 'Hộp thư đang trống',
              message: 'Thông báo mới sẽ xuất hiện tại đây.',
              icon: Icons.notifications_none_rounded,
            );
          }
          return RefreshIndicator.adaptive(
            onRefresh: () async => onRetry(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 9),
              itemBuilder: (context, index) {
                final item = items[index];
                final unread = item['read'] != true && item['isRead'] != true;
                return Card(
                  margin: EdgeInsets.zero,
                  color: unread
                      ? accent.withValues(alpha: .07)
                      : Theme.of(context).colorScheme.surface,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    leading: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          backgroundColor: accent.withValues(alpha: .12),
                          child: Icon(Icons.campaign_outlined, color: accent),
                        ),
                        if (unread)
                          Positioned(
                            right: -1,
                            top: -1,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      '${item['title'] ?? 'Thông báo'}',
                      style: TextStyle(
                        fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${item['body'] ?? item['message'] ?? ''}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      final id = item['id'];
                      if (unread && id != null) {
                        await context.read<AppSession>().api.dio.post(
                          '/notifications/$id/read',
                        );
                        onRetry();
                      }
                      if (context.mounted) {
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          builder: (_) => _MessageDetail(item: item),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      );
}

class _ThreadsTab extends StatelessWidget {
  const _ThreadsTab({
    required this.future,
    required this.accent,
    required this.onRetry,
  });
  final Future<List<Map<String, dynamic>>> future;
  final Color accent;
  final VoidCallback onRetry;

  @override
  Widget build(
    BuildContext context,
  ) => AsyncStateView<List<Map<String, dynamic>>>(
    future: future,
    onRetry: onRetry,
    builder: (context, items) {
      if (items.isEmpty) {
        return const EmptyState(
          title: 'Chưa có cuộc trao đổi',
          message: 'Danh sách chỉ hiển thị những người bạn được phép nhắn.',
          icon: Icons.forum_outlined,
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 9),
        itemBuilder: (context, index) {
          final item = items[index];
          final name =
              '${item['fullName'] ?? item['name'] ?? item['participantName'] ?? 'Cuộc trao đổi'}';
          final unread =
              int.tryParse('${item['unread'] ?? item['unreadCount'] ?? 0}') ??
              0;
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: accent.withValues(alpha: .12),
                child: Text(
                  name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
                  style: TextStyle(color: accent, fontWeight: FontWeight.w800),
                ),
              ),
              title: Text(name),
              subtitle: Text(
                '${item['lastMessage'] ?? item['message'] ?? 'Bắt đầu trao đổi'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: unread > 0
                  ? Badge(backgroundColor: accent, label: Text('$unread'))
                  : const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    userId:
                        '${item['userId'] ?? item['participantId'] ?? item['id']}',
                    name: name,
                    accent: accent,
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.accent,
  });
  final String userId;
  final String name;
  final Color accent;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final input = TextEditingController();
  late Future<List<Map<String, dynamic>>> messages;

  @override
  void initState() {
    super.initState();
    messages = load();
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> load() => context
      .read<AppSession>()
      .api
      .list('/chat/messages', query: {'withUserId': widget.userId});

  Future<void> send() async {
    final text = input.text.trim();
    if (text.isEmpty) return;
    final session = context.read<AppSession>();
    input.clear();
    await session.api.post('/chat/messages', {
      'toUserId': widget.userId,
      'body': text,
    });
    await session.refreshUnreadCounts();
    if (mounted) setState(() => messages = load());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.name)),
    body: Column(
      children: [
        Expanded(
          child: AsyncStateView<List<Map<String, dynamic>>>(
            future: messages,
            onRetry: () => setState(() => messages = load()),
            builder: (context, items) => items.isEmpty
                ? const EmptyState(
                    title: 'Bắt đầu cuộc trò chuyện',
                    message: 'Tin nhắn được bảo vệ theo quyền của hệ thống.',
                    icon: Icons.waving_hand_outlined,
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final item = items[items.length - 1 - index];
                      final mine =
                          item['mine'] == true ||
                          item['senderId'] ==
                              context.read<AppSession>().user?.id;
                      return Align(
                        alignment: mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 360),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: mine
                                ? widget.accent
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            '${item['body'] ?? item['message'] ?? ''}',
                            style: TextStyle(color: mine ? Colors.white : null),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => send(),
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: send,
                  style: IconButton.styleFrom(backgroundColor: widget.accent),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _MessageDetail extends StatelessWidget {
  const _MessageDetail({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item['title'] ?? 'Thông báo'}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          Text('${item['body'] ?? item['message'] ?? ''}'),
          if (item['createdAt'] != null) ...[
            const SizedBox(height: 16),
            Text(
              '${item['createdAt']}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    ),
  );
}
