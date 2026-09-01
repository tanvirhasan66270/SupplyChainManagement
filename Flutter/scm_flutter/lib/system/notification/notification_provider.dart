import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/system/notification/notification_repository.dart';


/// ১. NotificationRepository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(apiClientProvider));
});

/// (GET /api/notifications)
final notificationListProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repository = ref.watch(notificationRepositoryProvider);
  try {
    final list = await repository.getUserNotifications();
    final userIdStr = user.userId.toString();
    final userEmail = user.email.toLowerCase().trim();
    
    final userNotifications = list.where((item) {
      if (item is! Map) return true;
      final m = Map<String, dynamic>.from(item);
      final recipientId = (m['recipientId'] ?? m['userId'] ?? m['recipient'] ?? m['user_id'])?.toString().trim() ?? '';
      if (recipientId.isEmpty) return true;
      return recipientId == userIdStr || recipientId.toLowerCase() == userEmail;
    }).toList();

    return userNotifications;
  } catch (_) {
    return [];
  }
});

/// (GET /api/notifications/unread-count)
final notificationUnreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  try {
    final list = await ref.watch(notificationListProvider.future);
    final unreadCount = list.where((item) {
      if (item is! Map) return false;
      final m = Map<String, dynamic>.from(item);
      final isRead = m['isRead'] ?? m['read'] ?? false;
      return !isRead;
    }).length;
    return unreadCount;
  } catch (_) {
    return 0;
  }
});