import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/manager_model.dart';
import 'package:scm_flutter/manager/data/manager_repository.dart';

final managerRepositoryProvider = Provider<ManagerRepository>((ref) {
  return ManagerRepository(ref.watch(apiClientProvider));
});

final managerListProvider = FutureProvider.autoDispose<List<ManagerResponseModel>>((ref) async {
  final repo = ref.watch(managerRepositoryProvider);
  return await repo.findAll();
});

final managerControllerProvider = StateNotifierProvider<ManagerController, AsyncValue<void>>((ref) {
  final repo = ref.watch(managerRepositoryProvider);
  return ManagerController(repo, ref);
});

class ManagerController extends StateNotifier<AsyncValue<void>> {
  final ManagerRepository _repository;
  final Ref _ref;

  ManagerController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> saveManager(ManagerRequestModel request, File? file) async {
    state = const AsyncValue.loading();
    try {
      await _repository.save(request, file);
      _ref.invalidate(managerListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateManager(int id, ManagerRequestModel request, File? file) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request, file);
      _ref.invalidate(managerListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteManager(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(managerListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}