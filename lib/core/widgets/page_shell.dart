import 'package:flutter/material.dart';

class PageShell extends StatelessWidget {
  const PageShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: RefreshIndicator.adaptive(
      onRefresh: () async {},
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Theme.of(
              context,
            ).scaffoldBackgroundColor.withValues(alpha: .94),
            titleSpacing: 20,
            toolbarHeight: 82,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: actions,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            sliver: SliverToBoxAdapter(child: child),
          ),
        ],
      ),
    ),
  );
}
