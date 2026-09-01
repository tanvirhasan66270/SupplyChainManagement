import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class CustomerOrderRepository {
  CustomerOrderRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  /// 1. Place a New Order (POST /api/customerOrders)
  Future<CustomerOrderResponse> save(CustomerOrderRequest dto, {MultipartFile? imageFile}) async {
    FormData formData = FormData.fromMap({
      'order': MultipartFile.fromString(
        jsonEncode(dto.toJson()),
        contentType: DioMediaType('application', 'json'),
      ),
      'image': ?imageFile,
    });

    final res = await _dio.post(ApiConstants.createCustomerOrder, data: formData);
    return CustomerOrderResponse.fromJson(res.data as Map<String, dynamic>);
  }

  /// 2. General Update Order Metadata (PUT /api/customerOrders/{id})
  Future<CustomerOrderResponse> updateOrder(int id, CustomerOrderRequest dto, {MultipartFile? imageFile}) async {
    FormData formData = FormData.fromMap({
      'order': MultipartFile.fromString(
        jsonEncode(dto.toJson()),
        contentType: DioMediaType('application', 'json'),
      ),
      'image': ?imageFile,
    });

    final res = await _dio.put(ApiConstants.customerOrderById(id), data: formData);
    return CustomerOrderResponse.fromJson(res.data as Map<String, dynamic>);
  }

  /// 3. Get All Orders / Customer Specific Orders (GET /api/customerOrders)
  Future<List<CustomerOrderResponse>> findAll() async {
    try {
      final res = await _dio.get(ApiConstants.customerOrders);
      if (res.statusCode == 204 || res.data == null || res.data is! List) return [];
      return (res.data as List)
          .map((e) => CustomerOrderResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// 4. Get By Customer Email/Username (GET /api/customerOrders/customer)
  Future<List<CustomerOrderResponse>> getByCustomerEmail() async {
    try {
      final res = await _dio.get(ApiConstants.customerOrdersByEmail);
      if (res.statusCode == 204 || res.data == null || res.data is! List) return [];
      return (res.data as List)
          .map((e) => CustomerOrderResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// 5. Find Single Order Context By ID (GET /api/customerOrders/{id})
  Future<CustomerOrderResponse> getById(int id) async {
    final res = await _dio.get(ApiConstants.customerOrderById(id));
    return CustomerOrderResponse.fromJson(res.data as Map<String, dynamic>);
  }

  /// 6. Delete Order Record (DELETE /api/customerOrders/{id})
  Future<String> deleteOrder(int id) async {
    final res = await _dio.delete(ApiConstants.customerOrderById(id));
    return res.data.toString();
  }

  /// 7. Live Track Package via Order Number (GET /api/customerOrders/track?orderNumber=...)
  Future<CustomerOrderResponse> trackOrderByNumber(String orderNumber) async {
    final res = await _dio.get(
      ApiConstants.trackCustomerOrder,
      queryParameters: {'orderNumber': orderNumber},
    );
    return CustomerOrderResponse.fromJson(res.data as Map<String, dynamic>);
  }

  /// 8. Dedicated Status Lifecycle Update Endpoint (PATCH /api/customerOrders/{id}/status?status=...)
  Future<CustomerOrderResponse> updateOrderStatus(int id, String status) async {
    final res = await _dio.patch(
      ApiConstants.updateCustomerOrderStatus(id),
      queryParameters: {'status': status},
    );
    return CustomerOrderResponse.fromJson(res.data as Map<String, dynamic>);
  }

  /// 9. Two-Step Email Link Verification Webhook (GET /api/customerOrders/verify-link)
  Future<String> verifyPaymentLink({
    required int orderId,
    required double amountPaid,
    required String method,
  }) async {
    final res = await _dio.get(
      ApiConstants.verifyPaymentLink,
      queryParameters: {
        'orderId': orderId,
        'amountPaid': amountPaid,
        'method': method,
      },
    );
    return res.data.toString();
  }
}