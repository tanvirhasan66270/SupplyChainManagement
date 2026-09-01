import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/po_line_item_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class POLineItemRepository {
  POLineItemRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  // (GET /api/po-line-items or fallback to /api/order-items)
  Future<List<POLineItemResponseDTO>> findAll() async {
    try {
      try {
        final response = await _dio.get(ApiConstants.poLineItems);
        final List data = response.data ?? [];
        return data.map((e) => POLineItemResponseDTO.fromJson(e)).toList();
      } catch (_) {
        final response = await _dio.get(ApiConstants.orderItems);
        final List data = response.data ?? [];
        return data.map((e) => POLineItemResponseDTO.fromJson(e)).toList();
      }
    } catch (e) {
      throw Exception('Failed to load PO line items: $e');
    }
  }

  // (GET /api/po-line-items/{id} or fallback to /api/order-items/{id})
  Future<POLineItemResponseDTO> getById(int id) async {
    try {
      try {
        final response = await _dio.get(ApiConstants.poLineItemById(id));
        return POLineItemResponseDTO.fromJson(response.data);
      } catch (_) {
        final response = await _dio.get(ApiConstants.orderItemById(id));
        return POLineItemResponseDTO.fromJson(response.data);
      }
    } catch (e) {
      throw Exception('Failed to get PO line item by id: $e');
    }
  }

  // (GET /api/po-line-items/order/{orderId} or fallback to /api/order-items/order/{orderId})
  Future<List<POLineItemResponseDTO>> getByOrderId(int orderId) async {
    try {
      try {
        final response = await _dio.get('po-line-items/order/$orderId');
        final List data = response.data ?? [];
        return data.map((e) => POLineItemResponseDTO.fromJson(e)).toList();
      } catch (_) {
        final response = await _dio.get(ApiConstants.orderItemsByOrderId(orderId));
        final List data = response.data ?? [];
        return data.map((e) => POLineItemResponseDTO.fromJson(e)).toList();
      }
    } catch (e) {
      throw Exception('Failed to load order items by order id: $e');
    }
  }

  // (GET /api/po-line-items/track/{trackingNumber})
  Future<POLineItemResponseDTO> trackByNumber(String trackingNumber) async {
    try {
      final response = await _dio.get(ApiConstants.trackPoLineItem(trackingNumber));
      return POLineItemResponseDTO.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to track shipment by number: $e');
    }
  }

  // (POST /api/po-line-items or fallback to /api/order-items)
  Future<POLineItemResponseDTO> save(POLineItemRequestDTO request) async {
    try {
      try {
        final response = await _dio.post(ApiConstants.poLineItems, data: request.toJson());
        return POLineItemResponseDTO.fromJson(response.data);
      } catch (_) {
        final response = await _dio.post(ApiConstants.orderItems, data: request.toJson());
        return POLineItemResponseDTO.fromJson(response.data);
      }
    } catch (e) {
      throw Exception('Failed to save PO line item: $e');
    }
  }

  // (PUT /api/po-line-items/{id} or fallback to /api/order-items/{id})
  Future<POLineItemResponseDTO> update(int id, POLineItemRequestDTO request) async {
    try {
      try {
        final response = await _dio.put(ApiConstants.poLineItemById(id), data: request.toJson());
        return POLineItemResponseDTO.fromJson(response.data);
      } catch (_) {
        final response = await _dio.put(ApiConstants.orderItemById(id), data: request.toJson());
        return POLineItemResponseDTO.fromJson(response.data);
      }
    } catch (e) {
      throw Exception('Failed to update PO line item: $e');
    }
  }

  // (DELETE /api/po-line-items/{id} or fallback to /api/order-items/{id})
  Future<void> delete(int id) async {
    try {
      try {
        await _dio.delete(ApiConstants.poLineItemById(id));
      } catch (_) {
        await _dio.delete(ApiConstants.orderItemById(id));
      }
    } catch (e) {
      throw Exception('Failed to delete PO line item: $e');
    }
  }
}