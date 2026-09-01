import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/entity/daily_report_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class DailyReportRepository {
  DailyReportRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  //(GET /api/reports)
  Future<List<DailyReportResponseModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.reports);
      final List data = response.data ?? [];
      return data.map((e) => DailyReportResponseModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load daily reports: $e');
    }
  }

  //  (GET /api/reports/{id})
  Future<DailyReportResponseModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.reportById(id));
      return DailyReportResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get daily report by id: $e');
    }
  }

  // (POST /api/reports with multipart attachment)
  Future<DailyReportResponseModel> create(DailyReportRequestModel request, XFile? attachment) async {
    try {
      FormData formData = FormData.fromMap({
        'report': MultipartFile.fromBytes(
          utf8.encode(jsonEncode(request.toJson())),
          filename: 'report.json',
          contentType: DioMediaType('application', 'json'),
        ),
        if (attachment != null)
          'attachment': await MultipartFile.fromFile(
            attachment.path,
            filename: attachment.name,
          ),
      });

      final response = await _dio.post(
        ApiConstants.reports,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return DailyReportResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create daily report: $e');
    }
  }

  // (PUT /api/reports/{id} with multipart attachment)
  Future<DailyReportResponseModel> update(int id, DailyReportRequestModel request, XFile? attachment) async {
    try {
      FormData formData = FormData.fromMap({
        'report': MultipartFile.fromBytes(
          utf8.encode(jsonEncode(request.toJson())),
          filename: 'report.json',
          contentType: DioMediaType('application', 'json'),
        ),
        if (attachment != null)
          'attachment': await MultipartFile.fromFile(
            attachment.path,
            filename: attachment.name,
          ),
      });

      final response = await _dio.put(
        ApiConstants.reportById(id),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return DailyReportResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update daily report: $e');
    }
  }

  //  (PATCH /api/reports/approve/{id})
  Future<DailyReportResponseModel> approve(int id) async {
    try {
      final response = await _dio.patch(ApiConstants.approveReport(id));
      return DailyReportResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to approve daily report: $e');
    }
  }

  // (DELETE /api/reports/{id})
  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.reportById(id));
    } catch (e) {
      throw Exception('Failed to delete daily report: $e');
    }
  }
}