import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/product_requirement.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class ProductRequirementRepository {
  ProductRequirementRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  //  (GET /api/product-requirements)
  Future<List<ProductRequirementResponse>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.productRequirements);
      final List data = response.data ?? [];
      return data.map((e) => ProductRequirementResponse.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load product requirements: $e');
    }
  }

  //(GET /api/product-requirements/{id})
  Future<ProductRequirementResponse> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.productRequirementById(id));
      return ProductRequirementResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get product requirement by id: $e');
    }
  }

  // (POST /api/product-requirements)
  Future<ProductRequirementResponse> save(ProductRequirementRequest request) async {
    try {
      final response = await _dio.post(ApiConstants.productRequirements, data: request.toJson());
      return ProductRequirementResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save product requirement: $e');
    }
  }

  // (PUT /api/product-requirements/{id})
  Future<ProductRequirementResponse> update(int id, ProductRequirementRequest request) async {
    try {
      final response = await _dio.put(ApiConstants.productRequirementById(id), data: request.toJson());
      return ProductRequirementResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update product requirement: $e');
    }
  }

  //  (PATCH /api/product-requirements/{id}/status)
  Future<ProductRequirementResponse> updateStatus(int id, String status) async {
    try {
      final response = await _dio.patch(
        ApiConstants.updateProductRequirementStatus(id),
        queryParameters: {'status': status},
      );
      return ProductRequirementResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update product requirement status: $e');
    }
  }

  //  (DELETE /api/product-requirements/{id})
  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.productRequirementById(id));
    } catch (e) {
      throw Exception('Failed to delete product requirement: $e');
    }
  }
}