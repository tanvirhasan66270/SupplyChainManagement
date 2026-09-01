import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/catagory_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class CategoryRepository {
  CategoryRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  /// (GET /api/categories )
  Future<List<CategoryResponseModel>> getAll() async {
    final res = await _dio.get(ApiConstants.categories);
    if (res.statusCode == 204 || res.data == null) return [];
    return (res.data as List)
        .map((e) => CategoryResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// (POST)
  Future<CategoryResponseModel> save(CategoryRequestModel dto) async {
    final res = await _dio.post(ApiConstants.categories, data: dto.toJson());
    return CategoryResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  /// (PUT /api/categories/{id})
  Future<CategoryResponseModel> update(int id, CategoryRequestModel dto) async {
    final res = await _dio.put(ApiConstants.categoryById(id), data: dto.toJson());
    return CategoryResponseModel.fromJson(res.data as Map<String, dynamic>);
  }

  /// (DELETE /api/categories/{id})
  Future<String> delete(int id) async {
    final res = await _dio.delete(ApiConstants.categoryById(id));
    return res.data.toString();
  }

  
}