import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/vehicle_model.dart';
import 'package:scm_flutter/logistics_officer/data/vehicle_repository.dart';

// ১. Repository Provider
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository(ref.watch(apiClientProvider));
});

// ২. List Provider
final vehicleListProvider = FutureProvider.autoDispose<List<VehicleResponseModel>>((ref) async {
  final repo = ref.watch(vehicleRepositoryProvider);
  return await repo.findAll();
});

// ৩. Controller / Notifier (Create, Update, Delete)
final vehicleControllerProvider = StateNotifierProvider<VehicleController, AsyncValue<void>>((ref) {
  final repo = ref.watch(vehicleRepositoryProvider);
  return VehicleController(repo, ref);
});

class VehicleController extends StateNotifier<AsyncValue<void>> {
  final VehicleRepository _repository;
  final Ref _ref;

  VehicleController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> createVehicle(VehicleRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.create(request);
      _ref.invalidate(vehicleListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateVehicle(int id, VehicleRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request);
      _ref.invalidate(vehicleListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteVehicle(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(vehicleListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}