import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/entity/supplier_model.dart';
import 'package:scm_flutter/suppplier/data/supplier_repository.dart';
import 'package:scm_flutter/auth/helperProvider.dart';

//  Supplier Repository Provider
final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepository(ref.watch(apiClientProvider));
});

final supplierListProvider = FutureProvider.autoDispose<List<SupplierResponseDTO>>((ref) async {
  final repo = ref.watch(supplierRepositoryProvider);
  return await repo.getAll();
});

final supplierByUserIdProvider = FutureProvider.autoDispose.family<SupplierResponseDTO, int>((ref, userId) async {
  final repo = ref.watch(supplierRepositoryProvider);
  return await repo.findByUserId(userId);
});

// Supplier Controller / Notifier (Create, Update, Delete)
final supplierControllerProvider = StateNotifierProvider<SupplierController, AsyncValue<void>>((ref) {
  final repo = ref.watch(supplierRepositoryProvider);
  return SupplierController(repo, ref);
});

class SupplierController extends StateNotifier<AsyncValue<void>> {
  final SupplierRepository _repository;
  final Ref _ref;

  SupplierController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> createSupplier(SupplierRequestDTO request, File? imageFile) async {
    state = const AsyncValue.loading();
    try {
      await _repository.create(request, imageFile);
      _ref.invalidate(supplierListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateSupplier(int id, SupplierRequestDTO request, File? imageFile) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request, imageFile);
      _ref.invalidate(supplierListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteSupplier(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(supplierListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}