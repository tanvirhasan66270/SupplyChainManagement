import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/productModel.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class ProductRepository {
  ProductRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  ///  (GET /api/products)
  Future<List<ProductResponseModel>> getAll() async {
    final res = await _dio.get(ApiConstants.products);
    return (res.data as List)
        .map((e) => ProductResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// (POST /api/products)
  Future<ProductResponseModel> addProduct(ProductRequestModel dto, {MultipartFile? imageFile}) async {
    FormData formData = FormData.fromMap({
      'product': MultipartFile.fromString(
        jsonEncode(dto.toJson()),
        contentType: DioMediaType('application', 'json'),
      ),
      'image': ?imageFile,
    });

    final res = await _dio.post(ApiConstants.products, data: formData);
    return ProductResponseModel.fromJson(res.data as Map<String, dynamic>);
  }



  /// (PUT /api/products/{id})
  Future<ProductResponseModel> updateProduct(int id, ProductRequestModel dto, {MultipartFile? imageFile}) async {
    FormData formData = FormData.fromMap({
      'product': MultipartFile.fromString(
        jsonEncode(dto.toJson()),
        contentType: DioMediaType('application', 'json'),
      ),
      'image': ?imageFile,
    });

    final res = await _dio.put(ApiConstants.productById(id), data: formData);
    return ProductResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  /// (DELETE /api/products/{id})
  Future<String> deleteProduct(int id) async {
    final res = await _dio.delete(ApiConstants.productById(id));
    return res.data.toString();
  }

  /// Get Single Product By ID (GET /api/products/{id})
  Future<ProductResponseModel> getProductById(int id) async {
    final res = await _dio.get(ApiConstants.productById(id));
    return ProductResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<ProductResponseModel>> getProductsByCategoryId(int categoryId) async {
    try {
      final res = await _dio.get('products/category/$categoryId');
      if (res.statusCode == 204 || res.data == null) return [];
      return (res.data as List)
          .map((e) => ProductResponseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      final all = await getAll();
      return all.where((p) => p.categoryId == categoryId).toList();
    }
  }
}