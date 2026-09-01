import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/inventory_model.dart';
import 'package:scm_flutter/logistics_officer/data/inventory_repository.dart';

// ১. Inventory Repository Provider
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.watch(apiClientProvider));
});

// ২. Inventory List Provider
final inventoryListProvider = FutureProvider.autoDispose<List<InventoryResponseModel>>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return await repo.findAll();
});

// ৩. Inventory Controller / Notifier (Create, Update, Delete)
final inventoryControllerProvider = StateNotifierProvider<InventoryController, AsyncValue<void>>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return InventoryController(repo, ref);
});

class InventoryController extends StateNotifier<AsyncValue<void>> {
  final InventoryRepository _repository;
  final Ref _ref;

  InventoryController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> createInventory(InventoryRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.save(request);
      _ref.invalidate(inventoryListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateInventory(int id, InventoryRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request);
      _ref.invalidate(inventoryListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteInventory(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(inventoryListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}