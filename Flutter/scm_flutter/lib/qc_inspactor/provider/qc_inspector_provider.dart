import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/qc_inspactor_model.dart';
import 'package:scm_flutter/qc_inspactor/data/qc_inspector_repository.dart';

import 'package:scm_flutter/auth/authProvider.dart';

// ১. Repository Provider
final qcInspectorRepositoryProvider = Provider<QCInspectorRepository>((ref) {
  return QCInspectorRepository(ref.watch(apiClientProvider));
});

// ২. List Provider
final qcInspectorListProvider = FutureProvider.autoDispose<List<QCInspectorResponseModel>>((ref) async {
  final repo = ref.watch(qcInspectorRepositoryProvider);
  return await repo.findAll();
});

/// 2b. Current Logged-in QC Inspector Profile Provider
final currentQcInspectorProvider = FutureProvider.autoDispose<QCInspectorResponseModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final role = user.role.toUpperCase();
  if (role != 'QC_INSPECTOR' && role != 'ROLE_QC_INSPECTOR') {
    return null;
  }
  try {
    return await ref.watch(qcInspectorRepositoryProvider).getByUserId(user.userId);
  } catch (_) {
    return null;
  }
});

// ৩. Controller / Notifier (Save, Update, Delete )
final qcInspectorControllerProvider = StateNotifierProvider<QCInspectorController, AsyncValue<void>>((ref) {
  final repo = ref.watch(qcInspectorRepositoryProvider);
  return QCInspectorController(repo, ref);
});

class QCInspectorController extends StateNotifier<AsyncValue<void>> {
  final QCInspectorRepository _repository;
  final Ref _ref;

  QCInspectorController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> saveInspector(QCInspectorRequestModel request, XFile? image) async {
    state = const AsyncValue.loading();
    try {
      await _repository.save(request, image);
      _ref.invalidate(qcInspectorListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateInspector(int id, QCInspectorRequestModel request, XFile? image) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request, image);
      _ref.invalidate(qcInspectorListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteInspector(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(qcInspectorListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}