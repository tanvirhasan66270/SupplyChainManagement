import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/supplier_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';


/// Mirrors services/supplier.service.ts (multipart create/update, same as
/// the Angular `FormData` approach).
class SupplierRepository {
  SupplierRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  Future<SupplierResponseDTO> create(
      SupplierRequestDTO customer,
      File? image,
      ) async {
    final form = await _buildForm(customer, image);
    final res = await _dio.post(ApiConstants.suppliers, data: form);
    return SupplierResponseDTO.fromJson(res.data as Map<String, dynamic>);
  }

  Future<SupplierResponseDTO> update(
      int id,
      SupplierRequestDTO customer,
      File? image,
      ) async {
    final form = await _buildForm(customer, image);
    final res = await _dio.put(ApiConstants.supplierById(id), data: form);
    return SupplierResponseDTO.fromJson(res.data as Map<String, dynamic>);
  }

  Future<SupplierResponseDTO> findByUserId(int userId) async {
    final res = await _dio.get(ApiConstants.supplierByUserId(userId));
    return SupplierResponseDTO.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<SupplierResponseDTO>> getAll() async {
    final res = await _dio.get(ApiConstants.suppliers);
    return (res.data as List)
        .map((e) => SupplierResponseDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> delete(int id) async {
    await _dio.delete(ApiConstants.supplierById(id));
  }

  Future<FormData> _buildForm(SupplierRequestDTO procurement, File? image) async {
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