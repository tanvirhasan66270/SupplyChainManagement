import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/shipment_model.dart';
import 'package:scm_flutter/suppplier/data/shipment_repository.dart';

// Shipment Repository Provider
final shipmentRepositoryProvider = Provider<ShipmentRepository>((ref) {
  return ShipmentRepository(ref.watch(apiClientProvider));
});

// Shipment List Provider
final shipmentListProvider = FutureProvider.autoDispose<List<ShipmentResponseModel>>((ref) async {
  final repo = ref.watch(shipmentRepositoryProvider);
  return await repo.findAll();
});

final singleShipmentProvider = FutureProvider.autoDispose.family<ShipmentResponseModel, int>((ref, id) async {
  final repo = ref.watch(shipmentRepositoryProvider);
  return await repo.getById(id);
});

//  Shipment Controller / Notifier (Create, Update, Delete)
final shipmentControllerProvider = StateNotifierProvider<ShipmentController, AsyncValue<void>>((ref) {
  final repo = ref.watch(shipmentRepositoryProvider);
  return ShipmentController(repo, ref);
});

class ShipmentController extends StateNotifier<AsyncValue<void>> {
  final ShipmentRepository _repository;
  final Ref _ref;

  ShipmentController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> createShipment(ShipmentRequestModel request, File? podFile) async {
    state = const AsyncValue.loading();
    try {
      await _repository.save(request, podFile);
      _ref.invalidate(shipmentListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateShipment(int id, ShipmentRequestModel request, File? podFile) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request, podFile);
      _ref.invalidate(shipmentListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteShipment(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(shipmentListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}