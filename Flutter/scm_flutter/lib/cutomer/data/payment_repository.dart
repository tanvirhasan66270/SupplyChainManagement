import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/payment_statement_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class PaymentRepository {
  PaymentRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  /// (POST /api/payment-statements)
  Future<PaymentStatementResponse> addPayment(PaymentStatementRequest dto, {MultipartFile? imageFile}) async {
    FormData formData = FormData.fromMap({
      'payment': MultipartFile.fromString(
        jsonEncode(dto.toJson()),
        contentType: DioMediaType('application', 'json'),
      ),
      'image': ?imageFile,
    });

    final res = await _dio.post(ApiConstants.paymentStatements, data: formData);
    return PaymentStatementResponse.fromJson(res.data as Map<String, dynamic>);
  }

  /// (GET /api/payment-statements/order-number/{orderNumber})
  Future<List<PaymentStatementResponse>> getPaymentsByOrderNumber(String orderNumber) async {
    final res = await _dio.get(ApiConstants.paymentsByOrderNumber(orderNumber));
    if (res.statusCode == 204 || res.data == null) return [];
    return (res.data as List)
        .map((e) => PaymentStatementResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// (GET /api/payment-statements/order/{orderId})
  Future<List<PaymentStatementResponse>> getPaymentsByOrderId(int orderId) async {
    final res = await _dio.get(ApiConstants.paymentsByOrderId(orderId));
    if (res.statusCode == 204 || res.data == null) return [];
    return (res.data as List)
        .map((e) => PaymentStatementResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// (GET /api/payment-statements)
  Future<List<PaymentStatementResponse>> findAll() async {
    try {
      final res = await _dio.get(ApiConstants.paymentStatements);
      if (res.statusCode == 204 || res.data == null) return [];
      return (res.data as List)
          .map((e) => PaymentStatementResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// (PUT /api/payment-statements/{id}/status?status={status})
  Future<PaymentStatementResponse> updateStatus(int id, String status) async {
    final res = await _dio.put(
      ApiConstants.updatePaymentStatus(id),
      queryParameters: {'status': status},
    );
    return PaymentStatementResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
