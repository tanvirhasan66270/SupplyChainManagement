import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/stock_movement.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class StockMovementRepository {
  StockMovementRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  //  (GET /api/stock-movements)
  Future<List<StockMovementResponseModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.stockMovements);
      final List data = response.data ?? [];
      return data.map((e) => StockMovementResponseModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load stock movements: $e');
    }
  }

  // (GET /api/stock-movements/{id})
  Future<StockMovementResponseModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.stockMovementById(id));
      return StockMovementResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get stock movement by id: $e');
    }
  }

  // (POST /api/stock-movements)
  Future<StockMovementResponseModel> logMovement(StockMovementRequestModel request) async {
    try {
      final response = await _dio.post(ApiConstants.stockMovements, data: request.toJson());
      return StockMovementResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to log stock movement: $e');
    }
  }

  //  (DELETE /api/stock-movements/{id})
  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.stockMovementById(id));
    } catch (e) {
      throw Exception('Failed to delete stock movement: $e');
    }
  }
}