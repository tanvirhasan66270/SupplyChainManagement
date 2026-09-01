import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/procourment_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

/// Mirrors services/procourment.service.ts (multipart create/update, same as
/// the Angular `FormData` approach).
class ProcurementRepository {
  ProcurementRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  Future<ProcurementResponseModel> create(
      ProcurementRequestModel customer,
      File? image,
      ) async {
    final form = await _buildForm(customer, image);
    final res = await _dio.post(ApiConstants.customer, data: form);
    return ProcurementResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ProcurementResponseModel> update(
      int id,
      ProcurementRequestModel customer,
      File? image,
      ) async {
    final form = await _buildForm(customer, image);
    final res = await _dio.put(ApiConstants.customerById(id), data: form);
    return ProcurementResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ProcurementResponseModel> findByUserId(int userId) async {
    final res = await _dio.get(ApiConstants.customerByUserId(userId));
    return ProcurementResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<ProcurementResponseModel>> getAll() async {
    final res = await _dio.get(ApiConstants.customer);
    return (res.data as List)
        .map((e) => ProcurementResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FormData> _buildForm(ProcurementRequestModel procurement, File? image) async {
    return FormData.fromMap({
      // Backend reads this part as a raw JSON string (@RequestPart String)
      // then parses it — mirrors `formData.append('procurement', JSON.stringify(customer))`.
      'procurement': jsonEncode(procurement.toJson()),
      if (image != null)
        'file': await MultipartFile.fromFile(
          image.path,
          filename: image.uri.pathSegments.last,
        ),
    });
  }
}