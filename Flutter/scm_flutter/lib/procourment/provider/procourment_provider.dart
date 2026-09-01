import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/procourment_model.dart';
import 'package:scm_flutter/procourment/data/procourment_repository.dart';
import 'package:scm_flutter/util/apiClint.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiClient(storageService);
});

// ২. Procurement Repository Provider
final procurementRepositoryProvider = Provider<ProcurementRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProcurementRepository(apiClient);
});

// ৩. All Procurements Future Provider
final procurementListProvider = FutureProvider.autoDispose<List<ProcurementResponseModel>>((ref) async {
  final repo = ref.watch(procurementRepositoryProvider);
  return await repo.getAll();
});

// ৪. Single Procurement by User ID Future Provider
final procurementByUserIdProvider = FutureProvider.autoDispose.family<ProcurementResponseModel, int>((ref, userId) async {
  final repo = ref.watch(procurementRepositoryProvider);
  return await repo.findByUserId(userId);
});

// ৫. Current Logged-in Procurement Officer Profile
final currentProcurementProvider = FutureProvider.autoDispose<ProcurementResponseModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(procurementRepositoryProvider).findByUserId(user.userId);
});

// ৬. Procurement Dashboard Summary Provider
final procurementDashboardSummaryProvider = FutureProvider.autoDispose<({int totalPRs, int activeRfqs, int pendingPOs, List<dynamic> recentItems})>(
        (ref) async {
      final procurement = await ref.watch(currentProcurementProvider.future);
      if (procurement?.id == null) {
        return (totalPRs: 0, activeRfqs: 0, pendingPOs: 0, recentItems: const []);
      }

      return (
      totalPRs: 0,
      activeRfqs: 0,
      pendingPOs: 0,
      recentItems: const [],
      );
    });

// ৭. Procurement Controller / Notifier (Create & Update )
final procurementControllerProvider = StateNotifierProvider<ProcurementController, AsyncValue<void>>((ref) {
  final repo = ref.watch(procurementRepositoryProvider);
  return ProcurementController(repo, ref);
});

class ProcurementController extends StateNotifier<AsyncValue<void>> {
  final ProcurementRepository _repository;
  final Ref _ref;

  ProcurementController(this._repository, this._ref) : super(const AsyncValue.data(null));

  // Create Procurement
  Future<bool> createProcurement(ProcurementRequestModel request, File? image) async {
    state = const AsyncValue.loading();
    try {
      await _repository.create(request, image);
      _ref.invalidate(procurementListProvider);
      _ref.invalidate(currentProcurementProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  // Update Procurement
  Future<bool> updateProcurement(int id, ProcurementRequestModel request, File? image) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request, image);
      _ref.invalidate(procurementListProvider);
      _ref.invalidate(currentProcurementProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}