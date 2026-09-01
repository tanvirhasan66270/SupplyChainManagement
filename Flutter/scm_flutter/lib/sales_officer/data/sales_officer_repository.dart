import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/sales_officer_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

/// Mirrors services/SalesOfficer.service.ts (multipart create/update, same as
/// the Angular `FormData` approach).
class SalesOfficerRepository {
  SalesOfficerRepository(this._apiClient);

  late final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  Future<SalesOfficerResponseDTO> create(
      SalesOfficerRequestDTO salesOfficer,
      File? image,
      ) async {
    final form = await _buildForm(salesOfficer, image);
    final res = await _dio.post(ApiConstants.salesOfficers, data: form);
    return SalesOfficerResponseDTO.fromJson(res.data as Map<String, dynamic>);
  }

  Future<SalesOfficerResponseDTO> update(
      int id,
      SalesOfficerRequestDTO salesOfficer,
      File? image,
      ) async {
    final form = await _buildForm(salesOfficer, image);
    final res = await _dio.put(ApiConstants.salesOfficerById(id), data: form);
    return SalesOfficerResponseDTO.fromJson(res.data as Map<String, dynamic>);
  }

  Future<SalesOfficerResponseDTO?> findByUserId(int userId) async {
    try {
      final res = await _dio.get(ApiConstants.salesOfficerByUserId(userId));
      return SalesOfficerResponseDTO.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<SalesOfficerResponseDTO>> getAll() async {
    final res = await _dio.get(ApiConstants.salesOfficers);
    return (res.data as List)
        .map((e) => SalesOfficerResponseDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FormData> _buildForm(SalesOfficerRequestDTO salesOfficer, File? image) async {
    return FormData.fromMap({
      'salesOfficer': jsonEncode(salesOfficer.toJson()),
      if (image != null)
        'file': await MultipartFile.fromFile(
          image.path,
          filename: image.uri.pathSegments.last,
        ),
    });
  }
}