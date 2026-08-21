import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/avatar_view.dart';
import '../../core/widgets/glass_container.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/ui_provider.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ui = context.watch<UIProvider>();
    final auth = context.watch<AuthProvider>();
    final notifications = context.watch<NotificationProvider>();
    final profile = auth.profile;

    final navItems = [
      {'tab': AppTab.feed, 'label': 'Feed', 'icon': Icons.home_rounded},
      {'tab': AppTab.search, 'label': 'Search', 'icon': Icons.search_rounded},
      {'tab': AppTab.messages, 'label': 'Messages', 'icon': Icons.chat_bubble_outline_rounded},
      {'tab': AppTab.notifications, 'label': 'Notifications', 'icon': Icons.notifications_none_rounded, 'badge': notifications.unreadCount},
      {'tab': AppTab.clubs, 'label': 'Clubs', 'icon': Icons.groups_rounded},
      {'tab': AppTab.events, 'label': 'Events', 'icon': Icons.calendar_month_rounded},
      {'tab': AppTab.marketplace, 'label': 'Marketplace', 'icon': Icons.shopping_bag_outlined},
      {'tab': AppTab.confessions, 'label': 'Confessions', 'icon': Icons.lock_outline_rounded},
      {'tab': AppTab.polls, 'label': 'Polls', 'icon': Icons.bar_chart_rounded},
      {'tab': AppTab.pegasus, 'label': 'Pegasus AI', 'icon': Icons.auto_awesome_rounded, 'isAi': true},
    ];

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg950 : AppColors.lightBg950,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CampusX Logo / Brand (with hidden admin easter egg click handler)
          GestureDetector(
            onTap: () => ui.handleLogoClick(auth.isAdmin, context),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'X',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'CampusX',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            letterSpacing: -0.5,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Nav Items
          Expanded(
            child: ListView.separated(
              itemCount: navItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, i) {
                final item = navItems[i];
                final tab = item['tab'] as AppTab;
                final isSelected = ui.currentTab == tab;
                final isAi = item['isAi'] == true;
                final badgeCount = (item['badge'] as int?) ?? 0;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => ui.setTab(tab),
                    borderRadius: BorderRadius.circular(14),
                    hoverColor: isDark
                        ? Colors.white.withOpacity(0.04)
                        : Colors.black.withOpacity(0.03),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.violet500.withOpacity(0.16)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.violet500.withOpacity(0.4),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          if (isAi)
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.pegasusGradient.createShader(bounds),
                              child: Icon(
                                item['icon'] as IconData,
                                size: 18,
                                color: Colors.white,
                              ),
                            )
                          else
                            Icon(
                              item['icon'] as IconData,
                              size: 18,
                              color: isSelected
                                  ? (isDark ? AppColors.darkInk100 : AppColors.lightInk100)
                                  : (isDark ? AppColors.darkInk300 : AppColors.lightInk300),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected
                                    ? (isDark ? AppColors.darkInk100 : AppColors.lightInk100)
                                    : (isDark ? AppColors.darkInk300 : AppColors.lightInk300),
                              ),
                            ),
                          ),
                          if (badgeCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.coral500,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                badgeCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // User Profile Quick Bar at bottom
          if (profile != null)
            GlassContainer(
              padding: const EdgeInsets.all(10),
              borderRadius: 16,
              onTap: () => ui.openProfile(profile.username),
              child: Row(
                children: [
                  AvatarView(
                    url: profile.avatarUrl,
                    name: profile.fullName ?? profile.username,
                    size: 34,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile.fullName ?? profile.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '@${profile.username}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkInk400 : AppColors.lightInk400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 18),
                    onPressed: () => ui.setTab(AppTab.settings),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
