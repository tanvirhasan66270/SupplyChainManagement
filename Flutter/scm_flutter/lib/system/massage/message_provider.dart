import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/massage_model.dart';
import 'package:scm_flutter/system/massage/message_repository.dart';


/// ১. MessageRepository
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository(ref.watch(apiClientProvider));
});

/// (GET /api/messages/inbox)
final inboxProvider = FutureProvider.autoDispose<List<MessageResponseModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getInbox(userId: user?.userId.toString());
});

/// (GET /api/messages/chatlist)
final chatlistProvider = FutureProvider.autoDispose<List<ChatContactModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final repository = ref.watch(messageRepositoryProvider);
  try {
    final data = await repository.getChatlist(userId: user?.userId.toString());
    return data.map((e) => ChatContactModel.fromJson(e as Map<String, dynamic>)).toList();
  } catch (_) {
    return <ChatContactModel>[];
  }
});

/// (GET /api/messages/history)
final chatHistoryProvider = FutureProvider.autoDispose.family<List<MessageResponseModel>, String>((ref, contactId) async {
  final user = ref.watch(currentUserProvider);
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getChatHistory(contactId, userId: user?.userId.toString());
});

final selectedContactProvider = StateProvider<ChatContactModel?>((ref) => null);
