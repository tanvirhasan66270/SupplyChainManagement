import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/qc_inspaction_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class QCInspectionRepository {
  QCInspectionRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  // GET /api/qc-inspections)
  Future<List<QCInspectionResponseModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.qcInspections);
      if (response.statusCode == 204 || response.data == null) return [];
      final List data = response.data as List;
      return data.map((e) => QCInspectionResponseModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  //  (GET /api/qc-inspections/{id})
  Future<QCInspectionResponseModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.qcInspectionById(id));
      return QCInspectionResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get QC inspection by id: $e');
    }
  }

  //  (POST /api/qc-inspections with multipart 'inspection' & 'labTestReport')
  Future<QCInspectionResponseModel> save(QCInspectionRequestModel request, File? labTestReportFile) async {
    try {
      FormData formData = FormData.fromMap({
        'inspection': MultipartFile.fromBytes(
          utf8.encode(jsonEncode(request.toJson())),
          filename: 'inspection.json',
          contentType: DioMediaType('application', 'json'),
        ),
        if (labTestReportFile != null)
          'labTestReport': await MultipartFile.fromFile(
            labTestReportFile.path,
            filename: labTestReportFile.uri.pathSegments.last,
          ),
      });

      final response = await _dio.post(
        ApiConstants.qcInspections,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return QCInspectionResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save QC inspection: $e');
    }
  }

  //  (PUT /api/qc-inspections/{id} with multipart)
  Future<QCInspectionResponseModel> update(int id, QCInspectionRequestModel request, File? labTestReportFile) async {
    try {
      FormData formData = FormData.fromMap({
        'inspection': MultipartFile.fromBytes(
          utf8.encode(jsonEncode(request.toJson())),
          filename: 'inspection.json',
          contentType: DioMediaType('application', 'json'),
        ),
        if (labTestReportFile != null)
          'labTestReport': await MultipartFile.fromFile(
            labTestReportFile.path,
            filename: labTestReportFile.uri.pathSegments.last,
          ),
      });

      final response = await _dio.put(
        ApiConstants.qcInspectionById(id),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return QCInspectionResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update QC inspection: $e');
    }
  }

  // (DELETE /api/qc-inspections/{id})
  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.qcInspectionById(id));
    } catch (e) {
      throw Exception('Failed to delete QC inspection: $e');
    }
  }
}