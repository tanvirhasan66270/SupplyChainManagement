import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/customerModel.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

/// Mirrors services/customer.service.ts (multipart create/update, same as
/// the Angular `FormData` approach).
class CustomerRepository {
  CustomerRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  Future<CustomerResponseModel> create(
    CustomerRequestModel customer,
    File? image, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final form = await _buildForm(customer, image, imageBytes: imageBytes, imageName: imageName);
    final res = await _dio.post(ApiConstants.customer, data: form);
    return CustomerResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<CustomerResponseModel> update(
    int id,
    CustomerRequestModel customer,
    File? image, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final form = await _buildForm(customer, image, imageBytes: imageBytes, imageName: imageName);
    final res = await _dio.put(ApiConstants.customerById(id), data: form);
    return CustomerResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<CustomerResponseModel?> findByUserId(int userId) async {
    try {
      final res = await _dio.get(ApiConstants.customerByUserId(userId));
      return CustomerResponseModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<CustomerResponseModel>> getAll() async {
    final res = await _dio.get(ApiConstants.customer);
    return (res.data as List)
        .map((e) => CustomerResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FormData> _buildForm(
    CustomerRequestModel customer,
    File? image, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    dynamic imageFile;
    if (imageBytes != null) {
      imageFile = MultipartFile.fromBytes(
        imageBytes,
        filename: imageName ?? 'profile.jpg',
      );
    } else if (image != null && !kIsWeb) {
      imageFile = await MultipartFile.fromFile(
        image.path,
        filename: image.uri.pathSegments.last,
      );
    }

    return FormData.fromMap({
      'customer': jsonEncode(customer.toJson()),
      'image': ?imageFile,
    });
  }
}