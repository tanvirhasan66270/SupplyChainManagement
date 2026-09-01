import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/po_line_item_model.dart';
import 'package:scm_flutter/suppplier/data/po_line_item_repository.dart';

//  Repository Provider
final poLineItemRepositoryProvider = Provider<POLineItemRepository>((ref) {
  return POLineItemRepository(ref.watch(apiClientProvider));
});

//  All Line Items List Provider
final poLineItemListProvider = FutureProvider.autoDispose<List<POLineItemResponseDTO>>((ref) async {
  final repo = ref.watch(poLineItemRepositoryProvider);
  return await repo.findAll();
});

// Single Line Item Family Provider
final singlePoLineItemProvider = FutureProvider.autoDispose.family<POLineItemResponseDTO, int>((ref, id) async {
  final repo = ref.watch(poLineItemRepositoryProvider);
  return await repo.getById(id);
});

// Line Items by Order ID Family Provider
final poLineItemsByOrderIdProvider = FutureProvider.autoDispose.family<List<POLineItemResponseDTO>, int>((ref, orderId) async {
  final repo = ref.watch(poLineItemRepositoryProvider);
  return await repo.getByOrderId(orderId);
});

//  Controller / Notifier (Create, Update, Delete)
final poLineItemControllerProvider = StateNotifierProvider<POLineItemController, AsyncValue<void>>((ref) {
  final repo = ref.watch(poLineItemRepositoryProvider);
  return POLineItemController(repo, ref);
});

class POLineItemController extends StateNotifier<AsyncValue<void>> {
  final POLineItemRepository _repository;
  final Ref _ref;

  POLineItemController(this._repository, this._ref) : super(const AsyncValue.data(null));

  // Create Line Item
  Future<bool> createLineItem(POLineItemRequestDTO request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.save(request);
      _ref.invalidate(poLineItemListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  // Update Line Item (অথবা স্ট্যাটাস পরিবর্তন)
  Future<bool> updateLineItem(int id, POLineItemRequestDTO request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request);
      _ref.invalidate(poLineItemListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  // Delete Line Item
  Future<bool> deleteLineItem(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(poLineItemListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}