import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/inventory_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class InventoryRepository {
  InventoryRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  //  (GET /api/inventories)
  Future<List<InventoryResponseModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.inventories);
      final List data = response.data ?? [];
      return data.map((e) => InventoryResponseModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load inventory records: $e');
    }
  }

  //  (GET /api/inventories/{id})
  Future<InventoryResponseModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.inventoryById(id));
      return InventoryResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get inventory by id: $e');
    }
  }

  // (POST /api/inventories)
  Future<InventoryResponseModel> save(InventoryRequestModel request) async {
    try {
      final response = await _dio.post(ApiConstants.inventories, data: request.toJson());
      return InventoryResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save inventory record: $e');
    }
  }

  // (PUT /api/inventories/{id})
  Future<InventoryResponseModel> update(int id, InventoryRequestModel request) async {
    try {
      final response = await _dio.put(ApiConstants.inventoryById(id), data: request.toJson());
      return InventoryResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update inventory record: $e');
    }
  }

  // (DELETE /api/inventories/{id})
  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.inventoryById(id));
    } catch (e) {
      throw Exception('Failed to delete inventory record: $e');
    }
  }
}