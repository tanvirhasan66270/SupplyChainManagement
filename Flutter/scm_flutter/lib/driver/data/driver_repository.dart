import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/driver_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

/// Mirrors services/driver.service.ts (multipart create/update, same as
/// the Angular `FormData` approach).
class DriverRepository {
  DriverRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  //  (POST /api/drivers)
  Future<DriverResponseModel> create(
      DriverRequestModel driver,
      File? image,
      ) async {
    final form = await _buildForm(driver, image);
    final res = await _dio.post(ApiConstants.drivers, data: form);
    return DriverResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  // (PUT /api/drivers/{id})
  Future<DriverResponseModel> update(
      int id,
      DriverRequestModel driver,
      File? image,
      ) async {
    final form = await _buildForm(driver, image);
    final res = await _dio.put(ApiConstants.driverById(id), data: form);
    return DriverResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  // (GET /api/drivers/user/{userId})
  Future<DriverResponseModel> findByUserId(int userId) async {
    final res = await _dio.get(ApiConstants.driverByUserId(userId));
    return DriverResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  // (GET /api/drivers)
  Future<List<DriverResponseModel>> getAll() async {
    final res = await _dio.get(ApiConstants.drivers);
    return (res.data as List)
        .map((e) => DriverResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FormData> _buildForm(DriverRequestModel driver, File? image) async {
    return FormData.fromMap({
      // Backend reads this part as a raw JSON string (@RequestPart String)
      // then parses it — mirrors `formData.append('driver', JSON.stringify(driver))`.
      'driver': jsonEncode(driver.toJson()),
      if (image != null)
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.uri.pathSegments.last,
        ),
    });
  }
}