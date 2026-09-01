import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/letter_of_cradit_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class LetterOfCreditRepository {
  LetterOfCreditRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  // (GET /api/lc)
  Future<List<LetterOfCreditResponseModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.lcs);
      final List data = response.data ?? [];
      return data.map((e) => LetterOfCreditResponseModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load letters of credit: $e');
    }
  }

  //  (GET /api/lc/{id})
  Future<LetterOfCreditResponseModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.lcById(id));
      return LetterOfCreditResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get letter of credit by id: $e');
    }
  }

  // (POST /api/lc with multipart 'lcData' & 'file')
  Future<LetterOfCreditResponseModel> save(LetterOfCreditRequestModel request, File? file) async {
    try {
      FormData formData = FormData.fromMap({
        'lcData': MultipartFile.fromBytes(
          utf8.encode(jsonEncode(request.toJson())),
          filename: 'lcData.json',
          contentType: DioMediaType('application', 'json'),
        ),
        if (file != null)
          'file': await MultipartFile.fromFile(
            file.path,
            filename: file.uri.pathSegments.last,
          ),
      });

      final response = await _dio.post(
        ApiConstants.lcs,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return LetterOfCreditResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save letter of credit: $e');
    }
  }

  //  (PUT /api/lc/{id} with multipart)
  Future<LetterOfCreditResponseModel> update(int id, LetterOfCreditRequestModel request, File? file) async {
    try {
      FormData formData = FormData.fromMap({
        'lcData': MultipartFile.fromBytes(
          utf8.encode(jsonEncode(request.toJson())),
          filename: 'lcData.json',
          contentType: DioMediaType('application', 'json'),
        ),
        if (file != null)
          'file': await MultipartFile.fromFile(
            file.path,
            filename: file.uri.pathSegments.last,
          ),
      });

      final response = await _dio.put(
        ApiConstants.lcById(id),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return LetterOfCreditResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update letter of credit: $e');
    }
  }

  //  (PATCH /api/lc/amend/{id})
  Future<LetterOfCreditResponseModel> amendLC(int id, Map<String, dynamic> patchData) async {
    try {
      final response = await _dio.patch(
        ApiConstants.amendLc(id),
        data: patchData,
      );
      return LetterOfCreditResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to amend letter of credit: $e');
    }
  }

  // (DELETE /api/lc/{id})
  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.lcById(id));
    } catch (e) {
      throw Exception('Failed to delete letter of credit: $e');
    }
  }
}