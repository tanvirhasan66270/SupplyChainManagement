import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/purchase_requisition_model.dart';
import 'package:scm_flutter/procourment/data/purchase_requisition_repository.dart';

final purchaseRequisitionRepositoryProvider = Provider<PurchaseRequisitionRepository>((ref) {
  return PurchaseRequisitionRepository(ref.watch(apiClientProvider));
});

final purchaseRequisitionListProvider = FutureProvider.autoDispose<List<PurchaseRequisitionResponse>>((ref) async {
  final repo = ref.watch(purchaseRequisitionRepositoryProvider);
  return await repo.findAll();
});

//  (Create, Update, Delete, Approve, Reject )
final purchaseRequisitionControllerProvider = StateNotifierProvider<PurchaseRequisitionController, AsyncValue<void>>((ref) {
  final repo = ref.watch(purchaseRequisitionRepositoryProvider);
  return PurchaseRequisitionController(repo, ref);
});

class PurchaseRequisitionController extends StateNotifier<AsyncValue<void>> {
  final PurchaseRequisitionRepository _repository;
  final Ref _ref;

  PurchaseRequisitionController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> saveRequisition(PurchaseRequisitionRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.save(request);
      _ref.invalidate(purchaseRequisitionListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateRequisition(int id, PurchaseRequisitionRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request);
      _ref.invalidate(purchaseRequisitionListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteRequisition(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(purchaseRequisitionListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> authorizeApproval(int id) async {
    try {
      await _repository.approve(id);
      _ref.invalidate(purchaseRequisitionListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authorizeRejection(int id, String action) async {
    try {
      await _repository.rejectOrCancel(id, action);
      _ref.invalidate(purchaseRequisitionListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }
}