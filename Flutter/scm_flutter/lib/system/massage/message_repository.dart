import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/massage_model.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class MessageRepository {
  MessageRepository(this._apiClient);

  final dynamic _apiClient;
  Dio get _dio => _apiClient.dio;

  Options? _getOptions(String? userId) {
    if (userId == null || userId.isEmpty) return null;
    return Options(headers: {'X-User-Id': userId});
  }

  /// (POST /api/messages)
  Future<List<MessageResponseModel>> sendMessage(MessageRequestModel dto, {String? userId}) async {
    final res = await _dio.post(ApiConstants.messages, data: dto.toJson(), options: _getOptions(userId));
    if (res.statusCode == 204 || res.data == null) return [];
    return (res.data as List)
        .map((e) => MessageResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  ///  (GET /api/messages/inbox)
  Future<List<MessageResponseModel>> getInbox({String? userId}) async {
    final res = await _dio.get(ApiConstants.messageInbox, options: _getOptions(userId));
    if (res.statusCode == 204 || res.data == null) return [];
    return (res.data as List)
        .map((e) => MessageResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  ///(GET /api/messages/chatlist)
  Future<List<dynamic>> getChatlist({String? userId}) async {
    try {
      final res = await _dio.get(ApiConstants.messageChatlist, options: _getOptions(userId));
      if (res.statusCode == 204 || res.data == null || res.data is! List) return [];
      return res.data as List;
    } catch (_) {
      return [];
    }
  }

  /// (GET /api/messages/history?contactId=...)
  Future<List<MessageResponseModel>> getChatHistory(String contactId, {String? userId}) async {
    final res = await _dio.get(
      ApiConstants.messageHistory,
      queryParameters: {'contactId': contactId},
      options: _getOptions(userId),
    );
    if (res.statusCode == 204 || res.data == null) return [];
    return (res.data as List)
        .map((e) => MessageResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// (PATCH /api/messages/{id}/read)
  Future<void> markAsRead(int id, {String? userId}) async {
    await _dio.patch(ApiConstants.messageRead(id), options: _getOptions(userId));
  }
}