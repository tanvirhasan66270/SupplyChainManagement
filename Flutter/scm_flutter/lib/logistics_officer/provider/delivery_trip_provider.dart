import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/delivery_trip_model.dart';
import 'package:scm_flutter/logistics_officer/data/delivery_trip_repository.dart';

final deliveryTripRepositoryProvider = Provider<DeliveryTripRepository>((ref) {
  return DeliveryTripRepository(ref.watch(apiClientProvider));
});

final deliveryTripListProvider = FutureProvider.autoDispose<List<DeliveryTripResponseModel>>((ref) async {
  final repo = ref.watch(deliveryTripRepositoryProvider);
  return await repo.findAll();
});

final deliveryTripControllerProvider = StateNotifierProvider<DeliveryTripController, AsyncValue<void>>((ref) {
  final repo = ref.watch(deliveryTripRepositoryProvider);
  return DeliveryTripController(repo, ref);
});

class DeliveryTripController extends StateNotifier<AsyncValue<void>> {
  final DeliveryTripRepository _repository;
  final Ref _ref;

  DeliveryTripController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> createTrip(DeliveryTripRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.create(request);
      _ref.invalidate(deliveryTripListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateTrip(int id, DeliveryTripRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request);
      _ref.invalidate(deliveryTripListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> changeStatus(int id, String status, MultipartFile? signature, MultipartFile? photo) async {
    state = const AsyncValue.loading();
    try {
      await _repository.changeStatus(id, status, signature, photo);
      _ref.invalidate(deliveryTripListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteTrip(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(deliveryTripListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}