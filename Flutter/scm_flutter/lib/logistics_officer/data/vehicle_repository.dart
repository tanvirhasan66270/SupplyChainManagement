import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/vehicle_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class VehicleRepository {
  VehicleRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  // (GET /api/vehicles)
  Future<List<VehicleResponseModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.vehicles);
      final List data = response.data ?? [];
      return data.map((e) => VehicleResponseModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load vehicles: $e');
    }
  }

  // (GET /api/vehicles/{id})
  Future<VehicleResponseModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.vehicleById(id));
      return VehicleResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get vehicle by id: $e');
    }
  }

  //(POST /api/vehicles)
  Future<VehicleResponseModel> create(VehicleRequestModel request) async {
    try {
      final response = await _dio.post(ApiConstants.vehicles, data: request.toJson());
      return VehicleResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create vehicle: $e');
    }
  }

  // (PUT /api/vehicles/{id})
  Future<VehicleResponseModel> update(int id, VehicleRequestModel request) async {
    try {
      final response = await _dio.put(ApiConstants.vehicleById(id), data: request.toJson());
      return VehicleResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  //  (DELETE /api/vehicles/{id})
  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.vehicleById(id));
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }
}