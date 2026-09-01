import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/qc_inspaction_model.dart';
import 'package:scm_flutter/qc_inspactor/data/qc_inspection_repository.dart';

// ১. Repository Provider
final qcInspectionRepositoryProvider = Provider<QCInspectionRepository>((ref) {
  return QCInspectionRepository(ref.watch(apiClientProvider));
});

// ২. List Provider
final qcInspectionListProvider = FutureProvider.autoDispose<List<QCInspectionResponseModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(qcInspectionRepositoryProvider);
  try {
    return await repo.findAll();
  } catch (_) {
    return [];
  }
});

// ৩. Controller / Notifier (Save, Update, Delete )
final qcInspectionControllerProvider = StateNotifierProvider<QCInspectionController, AsyncValue<void>>((ref) {
  final repo = ref.watch(qcInspectionRepositoryProvider);
  return QCInspectionController(repo, ref);
});

class QCInspectionController extends StateNotifier<AsyncValue<void>> {
  final QCInspectionRepository _repository;
  final Ref _ref;

  QCInspectionController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> saveInspection(QCInspectionRequestModel request, File? file) async {
    state = const AsyncValue.loading();
    try {
      await _repository.save(request, file);
      _ref.invalidate(qcInspectionListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateInspection(int id, QCInspectionRequestModel request, File? file) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request, file);
      _ref.invalidate(qcInspectionListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteInspection(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(qcInspectionListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}