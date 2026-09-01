import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/cutomer/data/payment_repository.dart';
import 'package:scm_flutter/entity/payment_statement_model.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(apiClientProvider));
});

final orderPaymentsProvider = FutureProvider.autoDispose.family<List<PaymentStatementResponse>, String>((ref, orderNumber) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getPaymentsByOrderNumber(orderNumber);
});

final paymentStatementListProvider = FutureProvider.autoDispose<List<PaymentStatementResponse>>((ref) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.findAll();
});

final paymentStatementControllerProvider = StateNotifierProvider<PaymentStatementController, AsyncValue<void>>((ref) {
  final repo = ref.watch(paymentRepositoryProvider);
  return PaymentStatementController(repo, ref);
});

class PaymentStatementController extends StateNotifier<AsyncValue<void>> {
  final PaymentRepository _repository;
  final Ref _ref;

  PaymentStatementController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> updateStatus(int id, String status) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateStatus(id, status);
      _ref.invalidate(paymentStatementListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
