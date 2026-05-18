import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Notifications screen with categorized notification list.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Mark all read',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.spacingSm,
              ),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return _NotificationTile(notification: notif);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 64, color: AppColors.grey300),
          const SizedBox(height: AppTheme.spacingMd),
          Text('No notifications yet',
              style: AppTypography.titleMedium),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'You\'ll see booking updates,\npromotions, and alerts here.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Placeholder data ──
class _AppNotification {
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color color;
  final bool isRead;

  const _AppNotification({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}

const _notifications = <_AppNotification>[
  _AppNotification(
    title: 'Booking Confirmed',
    body: 'Your stay at Taj Mahal Palace has been confirmed for May 25-28.',
    time: '2 min ago',
    icon: Icons.check_circle_rounded,
    color: AppColors.success,
  ),
  _AppNotification(
    title: 'Guide Request',
    body: 'Rajesh Kumar accepted your guide booking for Ajanta Caves tour.',
    time: '1 hour ago',
    icon: Icons.person_rounded,
    color: AppColors.primary,
    isRead: true,
  ),
  _AppNotification(
    title: '🎉 Special Offer',
    body: 'Get 20% off on all homestays in Konkan this weekend!',
    time: '3 hours ago',
    icon: Icons.local_offer_rounded,
    color: AppColors.accent,
  ),
  _AppNotification(
    title: 'Trip Reminder',
    body: 'Your trip to Lonavala starts tomorrow. Don\'t forget to pack!',
    time: 'Yesterday',
    icon: Icons.alarm_rounded,
    color: AppColors.warning,
    isRead: true,
  ),
  _AppNotification(
    title: 'Review Request',
    body: 'How was your stay at Mountain View Resort? Share your experience.',
    time: '2 days ago',
    icon: Icons.star_rounded,
    color: AppColors.warning,
    isRead: true,
  ),
];

class _NotificationTile extends StatelessWidget {
  final _AppNotification notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: notification.isRead
          ? null
          : AppColors.primary.withValues(alpha: 0.03),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: notification.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Icon(notification.icon,
            color: notification.color, size: 24),
      ),
      title: Text(
        notification.title,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight:
              notification.isRead ? FontWeight.w400 : FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            notification.body,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            notification.time,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.grey400,
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      onTap: () {},
    );
  }
}
