import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/purchase-order_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class PurchaseOrderRepository {
  PurchaseOrderRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  // (GET /api/purchase-orders)
  Future<List<PurchaseOrderResponse>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.purchaseOrders);
      final List data = response.data ?? [];
      return data.map((e) => PurchaseOrderResponse.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load purchase orders: $e');
    }
  }

  //  (GET /api/purchase-orders/{id})
  Future<PurchaseOrderResponse> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.purchaseOrderById(id));
      return PurchaseOrderResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get purchase order by id: $e');
    }
  }

  Future<List<PurchaseOrderResponse>> getBySupplier(int supplierId) async {
    try {
      final response = await _dio.get(ApiConstants.purchaseOrdersBySupplier(supplierId));
      final List data = response.data ?? [];
      return data.map((e) => PurchaseOrderResponse.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load supplier purchase orders: $e');
    }
  }

  //  (POST /api/purchase-orders)
  Future<PurchaseOrderResponse> save(PurchaseOrderRequest request) async {
    try {
      final response = await _dio.post(ApiConstants.purchaseOrders, data: request.toJson());
      return PurchaseOrderResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save purchase order: $e');
    }
  }

  // (PUT /api/purchase-orders/{id})
  Future<PurchaseOrderResponse> update(int id, PurchaseOrderRequest request) async {
    try {
      final response = await _dio.put(ApiConstants.purchaseOrderById(id), data: request.toJson());
      return PurchaseOrderResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update purchase order: $e');
    }
  }

  // (PUT /api/purchase-orders/{id}/approve)
  Future<PurchaseOrderResponse> approve(int id) async {
    try {
      final response = await _dio.put(ApiConstants.approvePurchaseOrder(id));
      return PurchaseOrderResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to approve purchase order: $e');
    }
  }

  Future<PurchaseOrderResponse> updateStatus(int id, String status) async {
    try {
      final response = await _dio.put(
        ApiConstants.updatePurchaseOrderStatus(id),
        queryParameters: {'status': status},
      );
      return PurchaseOrderResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update purchase order status: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.purchaseOrderById(id));
    } catch (e) {
      throw Exception('Failed to delete purchase order: $e');
    }
  }
}