import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/commercial_officer/data/lc_bank_repository.dart';
import 'package:scm_flutter/entity/lc_bank.dart';

// ১. Repository Provider
final lcBankRepositoryProvider = Provider<LCBankRepository>((ref) {
  return LCBankRepository(ref.watch(apiClientProvider));
});

// ২. List Provider
final lcBankListProvider = FutureProvider.autoDispose<List<LCBankResponseModel>>((ref) async {
  final repo = ref.watch(lcBankRepositoryProvider);
  return await repo.findAll();
});

// ৩. Controller / Notifier (Create, Update, Delete )
final lcBankControllerProvider = StateNotifierProvider<LCBankController, AsyncValue<void>>((ref) {
  final repo = ref.watch(lcBankRepositoryProvider);
  return LCBankController(repo, ref);
});

class LCBankController extends StateNotifier<AsyncValue<void>> {
  final LCBankRepository _repository;
  final Ref _ref;

  LCBankController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> createBank(LCBankRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.create(request);
      _ref.invalidate(lcBankListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateBank(int id, LCBankRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request);
      _ref.invalidate(lcBankListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteBank(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(lcBankListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}