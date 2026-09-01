import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/warehouse_model.dart';
import 'package:scm_flutter/logistics_officer/data/warehouse_repository.dart';

// ১. Warehouse Repository Provider
final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  return WarehouseRepository(ref.watch(apiClientProvider));
});

// ২. Warehouse List Provider
final warehouseListProvider = FutureProvider.autoDispose<List<WarehouseResponseModel>>((ref) async {
  final repo = ref.watch(warehouseRepositoryProvider);
  return await repo.findAll();
});

// ৩. Warehouse Controller / Notifier (Save, Update, Delete )
final warehouseControllerProvider = StateNotifierProvider<WarehouseController, AsyncValue<void>>((ref) {
  final repo = ref.watch(warehouseRepositoryProvider);
  return WarehouseController(repo, ref);
});

class WarehouseController extends StateNotifier<AsyncValue<void>> {
  final WarehouseRepository _repository;
  final Ref _ref;

  WarehouseController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> saveWarehouse(WarehouseRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.save(request);
      _ref.invalidate(warehouseListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateWarehouse(int id, WarehouseRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request);
      _ref.invalidate(warehouseListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteWarehouse(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(warehouseListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}