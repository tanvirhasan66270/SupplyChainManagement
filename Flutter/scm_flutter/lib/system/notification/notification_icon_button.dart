import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/system/notification/notification_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class DynamicNotificationButton extends ConsumerWidget {
  const DynamicNotificationButton({
    super.key,
    this.iconColor = Colors.black87,
    this.iconSize = 22.0,
  });

  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadNotificationAsync = ref.watch(notificationUnreadCountProvider);

    return IconButton(
      tooltip: 'Notifications',
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_outlined, color: iconColor, size: iconSize),
          unreadNotificationAsync.when(
            data: (count) {
              if (count <= 0) return const SizedBox.shrink();
              return Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: const BoxDecoration(
                    color: AppTheme.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),
        ],
      ),
      onPressed: () {
        Navigator.of(context).pushNamed('/notifications').then((_) {
          ref.invalidate(notificationUnreadCountProvider);
        });
      },
    );
  }
}
