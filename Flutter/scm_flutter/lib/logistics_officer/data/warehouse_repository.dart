import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/warehouse_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class WarehouseRepository {
  WarehouseRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  // (GET /api/warehouses)
  Future<List<WarehouseResponseModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.warehouse);
      final List data = response.data ?? [];
      return data.map((e) => WarehouseResponseModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load warehouses: $e');
    }
  }

  //  (GET /api/warehouses/{id})
  Future<WarehouseResponseModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.warehouseById(id));
      return WarehouseResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get warehouse by id: $e');
    }
  }

  //  (POST /api/warehouses)
  Future<WarehouseResponseModel> save(WarehouseRequestModel request) async {
    try {
      final response = await _dio.post(ApiConstants.warehouse, data: request.toJson());
      return WarehouseResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save warehouse: $e');
    }
  }

  // (PUT /api/warehouses/{id})
  Future<WarehouseResponseModel> update(int id, WarehouseRequestModel request) async {
    try {
      final response = await _dio.put(ApiConstants.warehouseById(id), data: request.toJson());
      return WarehouseResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update warehouse: $e');
    }
  }

  // (DELETE /api/warehouses/{id})
  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.warehouseById(id));
    } catch (e) {
      throw Exception('Failed to delete warehouse: $e');
    }
  }
}