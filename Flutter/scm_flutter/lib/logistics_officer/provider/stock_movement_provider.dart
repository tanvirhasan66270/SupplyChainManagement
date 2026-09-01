import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/stock_movement.dart';
import 'package:scm_flutter/logistics_officer/data/stock_movement_repository.dart';

// ১. Repository Provider
final stockMovementRepositoryProvider = Provider<StockMovementRepository>((ref) {
  return StockMovementRepository(ref.watch(apiClientProvider));
});

// ২. Stock Movement List Provider
final stockMovementListProvider = FutureProvider.autoDispose<List<StockMovementResponseModel>>((ref) async {
  final repo = ref.watch(stockMovementRepositoryProvider);
  return await repo.findAll();
});

// ৩. Controller / Notifier (Log & Delete)
final stockMovementControllerProvider = StateNotifierProvider<StockMovementController, AsyncValue<void>>((ref) {
  final repo = ref.watch(stockMovementRepositoryProvider);
  return StockMovementController(repo, ref);
});

class StockMovementController extends StateNotifier<AsyncValue<void>> {
  final StockMovementRepository _repository;
  final Ref _ref;

  StockMovementController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> logMovement(StockMovementRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.logMovement(request);
      _ref.invalidate(stockMovementListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteMovement(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(stockMovementListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}