import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/quatation_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class QuotationRepository {
  QuotationRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  //  (GET /api/quotations)
  Future<List<QuotationResponseModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.quotations);
      final List data = response.data ?? [];
      return data.map((e) => QuotationResponseModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load quotations: $e');
    }
  }

  //  (GET /api/quotations/{id})
  Future<QuotationResponseModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.quotationById(id));
      return QuotationResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get quotation by id: $e');
    }
  }

  //  (Multipart Request ছবি/ফাইলসহ)
  Future<QuotationResponseModel> save(QuotationRequestModel request, File? attachmentFile) async {
    try {
      final form = await _buildForm(request, attachmentFile);
      final response = await _dio.post(ApiConstants.quotations, data: form);
      return QuotationResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save quotation: $e');
    }
  }

  // (PUT /api/quotations/{id})
  Future<QuotationResponseModel> update(int id, QuotationRequestModel request) async {
    try {
      final response = await _dio.put(
        ApiConstants.quotationById(id),
        data: request.toJson(),
      );
      return QuotationResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update quotation: $e');
    }
  }

  // (PUT /api/quotations/{id}/status)
  Future<QuotationResponseModel> updateStatus(int id, String status) async {
    try {
      final response = await _dio.put(
        ApiConstants.updateQuotationStatus(id),
        queryParameters: {'status': status},
      );
      return QuotationResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update quotation status: $e');
    }
  }

  //  (DELETE /api/quotations/{id})
  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.quotationById(id));
    } catch (e) {
      throw Exception('Failed to delete quotation: $e');
    }
  }

  Future<FormData> _buildForm(QuotationRequestModel request, File? file) async {
    return FormData.fromMap({
      'quotation': jsonEncode(request.toJson()),
      if (file != null)
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.last,
        ),
    });
  }
}