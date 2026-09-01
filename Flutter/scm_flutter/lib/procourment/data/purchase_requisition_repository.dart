import 'package:dio/dio.dart';
import 'package:scm_flutter/entity/purchase_requisition_model.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class PurchaseRequisitionRepository {
  PurchaseRequisitionRepository(this._apiClient);

  final ApiClient _apiClient;
  Dio get _dio => _apiClient.dio;

  // (GET /api/purchase-requisitions)
  Future<List<PurchaseRequisitionResponse>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.purchaseRequisitions);
      final List data = response.data ?? [];
      return data.map((e) => PurchaseRequisitionResponse.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load requisitions: $e');
    }
  }

  // (POST /api/purchase-requisitions)
  Future<void> save(PurchaseRequisitionRequest request) async {
    try {
      await _dio.post(ApiConstants.purchaseRequisitions, data: request.toJson());
    } catch (e) {
      throw Exception('Failed to save requisition: $e');
    }
  }

  // (PUT /api/purchase-requisitions/{id})
  Future<void> update(int id, PurchaseRequisitionRequest request) async {
    try {
      await _dio.put(
        ApiConstants.purchaseRequisitionById(id),
        data: request.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to update requisition: $e');
    }
  }

  //  (DELETE /api/purchase-requisitions/{id})
  Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.purchaseRequisitionById(id));
    } catch (e) {
      throw Exception('Failed to delete requisition: $e');
    }
  }

  //  (Approve) (PUT /api/purchase-requisitions/{id}/approve)
  Future<void> approve(int id) async {
    try {
      await _dio.put(ApiConstants.approvePurchaseRequisition(id));
    } catch (e) {
      throw Exception('Failed to approve requisition: $e');
    }
  }

  // রি (PUT /api/purchase-requisitions/{id}/reject-or-cancel?actionType=...)
  Future<void> rejectOrCancel(int id, String actionType) async {
    try {
      await _dio.put(
        ApiConstants.rejectOrCancelPurchaseRequisition(id),
        queryParameters: {'actionType': actionType},
      );
    } catch (e) {
      throw Exception('Failed to $actionType requisition: $e');
    }
  }
}