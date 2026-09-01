import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/invoiceModel.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class InvoiceRepository {
  InvoiceRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  //  (GET /api/invoices)
  Future<List<InvoiceResponseModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.invoices);
      if (response.statusCode == 204 || response.data == null || response.data is! List) return [];
      final List data = response.data as List;
      return data.map((e) => InvoiceResponseModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // (GET /api/invoices/{id})
  Future<InvoiceResponseModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.invoiceById(id));
      return InvoiceResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get invoice by id: $e');
    }
  }

  //  (POST /api/invoices)
  Future<InvoiceResponseModel> create(InvoiceRequestModel request) async {
    try {
      final response = await _dio.post(ApiConstants.invoices, data: request.toJson());
      return InvoiceResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create invoice: $e');
    }
  }

  // (PUT /api/invoices/{id})
  Future<InvoiceResponseModel> update(int id, InvoiceRequestModel request) async {
    try {
      final response = await _dio.put(ApiConstants.invoiceById(id), data: request.toJson());
      return InvoiceResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update invoice: $e');
    }
  }

  //  (DELETE /api/invoices/{id})
  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.invoiceById(id));
    } catch (e) {
      throw Exception('Failed to delete invoice: $e');
    }
  }
}