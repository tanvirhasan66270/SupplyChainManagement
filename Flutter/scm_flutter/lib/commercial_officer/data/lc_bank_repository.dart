import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/lc_bank.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class LCBankRepository {
  LCBankRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  //  (GET /api/banks)
  Future<List<LCBankResponseModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.banks);
      final List data = response.data ?? [];
      return data.map((e) => LCBankResponseModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load banks: $e');
    }
  }

  //  (GET /api/banks/{id})
  Future<LCBankResponseModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.bankById(id));
      return LCBankResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get bank by id: $e');
    }
  }

  //(POST /api/banks)
  Future<LCBankResponseModel> create(LCBankRequestModel request) async {
    try {
      final response = await _dio.post(ApiConstants.banks, data: request.toJson());
      return LCBankResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create bank: $e');
    }
  }

  //  (PUT /api/banks/{id})
  Future<LCBankResponseModel> update(int id, LCBankRequestModel request) async {
    try {
      final response = await _dio.put(ApiConstants.bankById(id), data: request.toJson());
      return LCBankResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update bank: $e');
    }
  }

  //  (DELETE /api/banks/{id})
  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.bankById(id));
    } catch (e) {
      throw Exception('Failed to delete bank: $e');
    }
  }
}