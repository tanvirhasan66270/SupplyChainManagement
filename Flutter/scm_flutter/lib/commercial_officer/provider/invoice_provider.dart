import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/commercial_officer/data/invoice_repository.dart';
import 'package:scm_flutter/entity/invoiceModel.dart';

// ১. Repository Provider
final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepository(ref.watch(apiClientProvider));
});

// ২. List Provider
final invoiceListProvider = FutureProvider.autoDispose<List<InvoiceResponseModel>>((ref) async {
  final repo = ref.watch(invoiceRepositoryProvider);
  return await repo.findAll();
});

// ৩. Controller / Notifier (Create, Update, Delete )
final invoiceControllerProvider = StateNotifierProvider<InvoiceController, AsyncValue<void>>((ref) {
  final repo = ref.watch(invoiceRepositoryProvider);
  return InvoiceController(repo, ref);
});

class InvoiceController extends StateNotifier<AsyncValue<void>> {
  final InvoiceRepository _repository;
  final Ref _ref;

  InvoiceController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> createInvoice(InvoiceRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.create(request);
      _ref.invalidate(invoiceListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateInvoice(int id, InvoiceRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request);
      _ref.invalidate(invoiceListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteInvoice(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(invoiceListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}