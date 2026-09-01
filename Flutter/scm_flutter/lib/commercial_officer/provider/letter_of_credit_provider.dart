import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/commercial_officer/data/letter_of_credit_repository.dart';
import 'package:scm_flutter/entity/letter_of_cradit_model.dart';

// ১. Repository Provider
final letterOfCreditRepositoryProvider = Provider<LetterOfCreditRepository>((ref) {
  return LetterOfCreditRepository(ref.watch(apiClientProvider));
});

// ২. List Provider
final letterOfCreditListProvider = FutureProvider.autoDispose<List<LetterOfCreditResponseModel>>((ref) async {
  final repo = ref.watch(letterOfCreditRepositoryProvider);
  return await repo.findAll();
});

// ৩. Controller / Notifier (Save, Update, Amend, Delete )
final letterOfCreditControllerProvider = StateNotifierProvider<LetterOfCreditController, AsyncValue<void>>((ref) {
  final repo = ref.watch(letterOfCreditRepositoryProvider);
  return LetterOfCreditController(repo, ref);
});

class LetterOfCreditController extends StateNotifier<AsyncValue<void>> {
  final LetterOfCreditRepository _repository;
  final Ref _ref;

  LetterOfCreditController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> saveLC(LetterOfCreditRequestModel request, File? file) async {
    state = const AsyncValue.loading();
    try {
      await _repository.save(request, file);
      _ref.invalidate(letterOfCreditListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateLC(int id, LetterOfCreditRequestModel request, File? file) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request, file);
      _ref.invalidate(letterOfCreditListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> amendLC(int id, Map<String, dynamic> patchData) async {
    state = const AsyncValue.loading();
    try {
      await _repository.amendLC(id, patchData);
      _ref.invalidate(letterOfCreditListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteLC(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(letterOfCreditListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}