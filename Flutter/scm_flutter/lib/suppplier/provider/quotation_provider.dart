import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/quatation_model.dart';
import 'package:scm_flutter/suppplier/data/quatation_repository.dart';

// ১. Quotation Repository Provider
final quotationRepositoryProvider = Provider<QuotationRepository>((ref) {
  return QuotationRepository(ref.watch(apiClientProvider));
});

// ২. Quotation List Provider
final quotationListProvider = FutureProvider.autoDispose<List<QuotationResponseModel>>((ref) async {
  final repo = ref.watch(quotationRepositoryProvider);
  return await repo.findAll();
});

final singleQuotationProvider = FutureProvider.autoDispose.family<QuotationResponseModel, int>((ref, id) async {
  final repo = ref.watch(quotationRepositoryProvider);
  return await repo.getById(id);
});

// Quotation Controller / Notifier (Create, Update, Delete, Status Change)
final quotationControllerProvider = StateNotifierProvider<QuotationController, AsyncValue<void>>((ref) {
  final repo = ref.watch(quotationRepositoryProvider);
  return QuotationController(repo, ref);
});

class QuotationController extends StateNotifier<AsyncValue<void>> {
  final QuotationRepository _repository;
  final Ref _ref;

  QuotationController(this._repository, this._ref) : super(const AsyncValue.data(null));


  Future<bool> createQuotation(QuotationRequestModel request, File? file) async {
    state = const AsyncValue.loading();
    try {
      await _repository.save(request, file);
      _ref.invalidate(quotationListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }


  Future<bool> updateQuotation(int id, QuotationRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request);
      _ref.invalidate(quotationListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  //  (Pending, Approved)
  Future<bool> changeStatus(int id, String status) async {
    try {
      await _repository.updateStatus(id, status);
      _ref.invalidate(quotationListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateQuotationStatus(int id, String status) async {
    return changeStatus(id, status);
  }

  Future<bool> updateStatus(int id, String status) async {
    return changeStatus(id, status);
  }


  Future<bool> deleteQuotation(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(quotationListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}