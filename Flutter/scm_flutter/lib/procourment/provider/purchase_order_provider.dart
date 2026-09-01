import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/purchase-order_model.dart';
import 'package:scm_flutter/procourment/data/purchase_order_repository.dart';

// ১. Purchase Order Repository Provider
final purchaseOrderRepositoryProvider = Provider<PurchaseOrderRepository>((ref) {
  return PurchaseOrderRepository(ref.watch(apiClientProvider));
});

final purchaseOrderListProvider = FutureProvider.autoDispose<List<PurchaseOrderResponse>>((ref) async {
  final repo = ref.watch(purchaseOrderRepositoryProvider);
  return await repo.findAll();
});

final singlePurchaseOrderProvider = FutureProvider.autoDispose.family<PurchaseOrderResponse, int>((ref, id) async {
  final repo = ref.watch(purchaseOrderRepositoryProvider);
  return await repo.getById(id);
});

final purchaseOrdersBySupplierProvider = FutureProvider.autoDispose.family<List<PurchaseOrderResponse>, int>((ref, supplierId) async {
  final repo = ref.watch(purchaseOrderRepositoryProvider);
  return await repo.getBySupplier(supplierId);
});

//Purchase Order Controller / Notifier (Create, Update, Approve operation helder)
final purchaseOrderControllerProvider = StateNotifierProvider<PurchaseOrderController, AsyncValue<void>>((ref) {
  final repo = ref.watch(purchaseOrderRepositoryProvider);
  return PurchaseOrderController(repo, ref);
});

class PurchaseOrderController extends StateNotifier<AsyncValue<void>> {
  final PurchaseOrderRepository _repository;
  final Ref _ref;

  PurchaseOrderController(this._repository, this._ref) : super(const AsyncValue.data(null));

  // পারচেজ অর্ডার তৈরি করা
  Future<bool> createPurchaseOrder(PurchaseOrderRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.save(request);
      _ref.invalidate(purchaseOrderListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updatePurchaseOrder(int id, PurchaseOrderRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request);
      _ref.invalidate(purchaseOrderListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> approveOrder(int id) async {
    try {
      await _repository.approve(id);
      _ref.invalidate(purchaseOrderListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStatus(int id, String status) async {
    try {
      await _repository.updateStatus(id, status);
      _ref.invalidate(purchaseOrderListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePurchaseOrder(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(purchaseOrderListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}