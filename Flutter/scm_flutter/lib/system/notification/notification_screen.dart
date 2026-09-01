import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/system/notification/notification_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  IconData _getNotificationIcon(String type) {
    switch (type.toUpperCase()) {
      case 'SHIPMENT':
        return Icons.local_shipping_outlined;
      case 'TRIP_ALERT':
        return Icons.alt_route;
      case 'REPORT_APPROVED':
        return Icons.verified_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toUpperCase()) {
      case 'SHIPMENT':
        return AppTheme.primary;
      case 'TRIP_ALERT':
        return AppTheme.warning;
      case 'REPORT_APPROVED':
        return AppTheme.success;
      default:
        return AppTheme.indigo;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final currentUser = ref.watch(currentUserProvider);
    final userName = currentUser?.name ?? 'User';

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: const DynamicScmTopNavBar(
        showBackButton: true,
        title: 'My Notifications',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Action & Status Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.surfaceWhite,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active, color: AppTheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Notifications for $userName',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.dark),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await ref.read(notificationRepositoryProvider).markAllAsRead();
                      ref.invalidate(notificationListProvider);
                      ref.invalidate(notificationUnreadCountProvider);
                    },
                    icon: const Icon(Icons.done_all, size: 16, color: AppTheme.primary),
                    label: const Text('Mark all as read', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderGrey),

            Expanded(
              child: notificationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error loading notifications: $err')),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 64, color: AppTheme.grey),
                          SizedBox(height: 12),
                          Text('No notifications for you yet', style: TextStyle(color: AppTheme.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('You are all caught up with your activity alerts!', style: TextStyle(color: AppTheme.secondary, fontSize: 11)),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(notificationListProvider);
                      ref.invalidate(notificationUnreadCountProvider);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.borderGrey),
                      itemBuilder: (context, index) {
                        final item = Map<String, dynamic>.from(notifications[index] as Map);
                        final bool isRead = item['isRead'] ?? item['read'] ?? false;
                        final String title = item['title'] ?? 'System Notification';
                        final String message = item['message'] ?? '';
                        final String type = item['type'] ?? 'SHIPMENT';
                        final String createdAt = item['createdAt'] ?? item['date'] ?? '';
                        final int? id = item['id'];

                        final iconData = _getNotificationIcon(type);
                        final iconColor = _getNotificationColor(type);

                        return Container(
                          color: isRead ? AppTheme.surfaceWhite : AppTheme.primary.withValues(alpha: 0.05),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: iconColor.withValues(alpha: 0.15),
                                  child: Icon(iconData, color: iconColor, size: 20),
                                ),
                                if (!isRead)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.danger,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                      fontSize: 13,
                                      color: AppTheme.dark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (createdAt.isNotEmpty)
                                  Text(
                                    createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt,
                                    style: const TextStyle(fontSize: 9, color: AppTheme.grey),
                                  ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                message,
                                style: const TextStyle(fontSize: 11, color: AppTheme.secondary),
                              ),
                            ),
                            onTap: () async {
                              if (id != null && !isRead) {
                                await ref.read(notificationRepositoryProvider).markAsRead(id);
                                ref.invalidate(notificationListProvider);
                                ref.invalidate(notificationUnreadCountProvider);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
