import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/entity/qc_inspactor_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class QCInspectorRepository {
  QCInspectorRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  // (GET /api/qc-inspectors)
  Future<List<QCInspectorResponseModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.qcInspectors);
      final List data = response.data ?? [];
      return data.map((e) => QCInspectorResponseModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load QC inspectors: $e');
    }
  }

  //  (GET /api/qc-inspectors/{id})
  Future<QCInspectorResponseModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.qcInspectorById(id));
      return QCInspectorResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get QC inspector by id: $e');
    }
  }

  //  (GET /api/qc-inspectors/user/{id})
  Future<QCInspectorResponseModel> getByUserId(int userId) async {
    try {
      final response = await _dio.get(ApiConstants.qcInspectorByUserId(userId));
      return QCInspectorResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get QC inspector by user id: $e');
    }
  }

  //  (POST /api/qc-inspectors with multipart 'qcInspector' & 'image')
  Future<QCInspectorResponseModel> save(QCInspectorRequestModel request, XFile? image) async {
    try {
      FormData formData = FormData.fromMap({
        'qcInspector': MultipartFile.fromBytes(
          utf8.encode(jsonEncode(request.toJson())),
          filename: 'inspector.json',
          contentType: DioMediaType('application', 'json'),
        ),
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.name,
          ),
      });

      final response = await _dio.post(
        ApiConstants.qcInspectors,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return QCInspectorResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save QC inspector: $e');
    }
  }

  //(PUT /api/qc-inspectors/{id} with multipart)
  Future<QCInspectorResponseModel> update(int id, QCInspectorRequestModel request, XFile? image) async {
    try {
      FormData formData = FormData.fromMap({
        'qcInspector': MultipartFile.fromBytes(
          utf8.encode(jsonEncode(request.toJson())),
          filename: 'inspector.json',
          contentType: DioMediaType('application', 'json'),
        ),
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.name,
          ),
      });

      final response = await _dio.put(
        ApiConstants.qcInspectorById(id),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return QCInspectorResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update QC inspector: $e');
    }
  }

  // (DELETE /api/qc-inspectors/{id})
  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.qcInspectorById(id));
    } catch (e) {
      throw Exception('Failed to delete QC inspector: $e');
    }
  }
}