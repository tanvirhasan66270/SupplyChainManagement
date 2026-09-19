import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/manager_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class ManagerRepository {
  ManagerRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  Future<List<ManagerResponseModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.managers);
      final List data = response.data ?? [];
      return data.map((e) => ManagerResponseModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load managers: $e');
    }
  }

  Future<ManagerResponseModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.managerById(id));
      return ManagerResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get manager by id: $e');
    }
  }

  Future<ManagerResponseModel> save(ManagerRequestModel request, File? imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'manager': MultipartFile.fromBytes(
          utf8.encode(jsonEncode(request.toJson())),
          filename: 'manager.json',
          contentType: DioMediaType('application', 'json'),
        ),
        if (imageFile != null)
          'file': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.uri.pathSegments.last,
          ),
      });

      final response = await _dio.post(
        ApiConstants.managers,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return ManagerResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save manager: $e');
    }
  }

  Future<ManagerResponseModel> update(int id, ManagerRequestModel request, File? imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'manager': MultipartFile.fromBytes(
          utf8.encode(jsonEncode(request.toJson())),
          filename: 'manager.json',
          contentType: DioMediaType('application', 'json'),
        ),
        if (imageFile != null)
          'file': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.uri.pathSegments.last,
          ),
      });

      final response = await _dio.put(
        ApiConstants.managerById(id),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return ManagerResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update manager: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.managerById(id));
    } catch (e) {
      throw Exception('Failed to delete manager: $e');
    }
  }
}