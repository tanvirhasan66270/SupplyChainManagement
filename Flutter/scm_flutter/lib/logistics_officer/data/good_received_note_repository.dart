import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/grn_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class GoodReceivedNoteRepository {
  GoodReceivedNoteRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  Future<List<GoodsReceivedNoteResponseModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.goodsReceivedNotes);
      if (response.statusCode == 204 || response.data == null) return [];
      final List data = response.data as List;
      return data.map((e) => GoodsReceivedNoteResponseModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<GoodsReceivedNoteResponseModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.goodsReceivedNoteById(id));
      return GoodsReceivedNoteResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get GRN by id: $e');
    }
  }

  Future<GoodsReceivedNoteResponseModel> save(GoodsReceivedNoteRequestModel request) async {
    try {
      final response = await _dio.post(ApiConstants.goodsReceivedNotes, data: request.toJson());
      return GoodsReceivedNoteResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save GRN: $e');
    }
  }

  Future<GoodsReceivedNoteResponseModel> update(int id, GoodsReceivedNoteRequestModel request) async {
    try {
      final response = await _dio.put(ApiConstants.goodsReceivedNoteById(id), data: request.toJson());
      return GoodsReceivedNoteResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update GRN: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.goodsReceivedNoteById(id));
    } catch (e) {
      throw Exception('Failed to delete GRN: $e');
    }
  }
}