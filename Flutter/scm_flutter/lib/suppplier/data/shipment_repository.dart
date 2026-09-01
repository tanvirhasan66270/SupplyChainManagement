import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/shipment_model.dart'; 
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class ShipmentRepository {
  ShipmentRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  // (GET /api/shipments)
  Future<List<ShipmentResponseModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.shipments);
      final List data = response.data ?? [];
      return data.map((e) => ShipmentResponseModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load shipments: $e');
    }
  }

  //  (GET /api/shipments/{id})
  Future<ShipmentResponseModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.shipmentById(id));
      return ShipmentResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get shipment by id: $e');
    }
  }

  //  (Multipart Request podFile সহ)
  Future<ShipmentResponseModel> save(ShipmentRequestModel request, File? podFile) async {
    try {
      final form = await _buildForm(request, podFile);
      final response = await _dio.post(ApiConstants.shipments, data: form);
      return ShipmentResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save shipment: $e');
    }
  }

  //  (PUT /api/shipments/{id})
  Future<ShipmentResponseModel> update(int id, ShipmentRequestModel request, File? podFile) async {
    try {
      final form = await _buildForm(request, podFile);
      final response = await _dio.put(ApiConstants.shipmentById(id), data: form);
      return ShipmentResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update shipment: $e');
    }
  }

  //  (DELETE /api/shipments/{id})
  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.shipmentById(id));
    } catch (e) {
      throw Exception('Failed to delete shipment: $e');
    }
  }

  Future<FormData> _buildForm(ShipmentRequestModel request, File? file) async {
    return FormData.fromMap({
      'shipment': jsonEncode(request.toJson()),
      if (file != null)
        'podFile': await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.last,
        ),
    });
  }
}