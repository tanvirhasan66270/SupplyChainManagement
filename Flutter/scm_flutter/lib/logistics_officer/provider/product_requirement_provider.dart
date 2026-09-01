import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/product_requirement.dart';
import 'package:scm_flutter/logistics_officer/data/product_requirement_repository.dart';

// ১. Repository Provider
final productRequirementRepositoryProvider = Provider<ProductRequirementRepository>((ref) {
  return ProductRequirementRepository(ref.watch(apiClientProvider));
});

// ২. List Provider
final productRequirementListProvider = FutureProvider.autoDispose<List<ProductRequirementResponse>>((ref) async {
  final repo = ref.watch(productRequirementRepositoryProvider);
  return await repo.findAll();
});

// ৩. Controller / Notifier (Save, Update, Status, Delete)
final productRequirementControllerProvider = StateNotifierProvider<ProductRequirementController, AsyncValue<void>>((ref) {
  final repo = ref.watch(productRequirementRepositoryProvider);
  return ProductRequirementController(repo, ref);
});

class ProductRequirementController extends StateNotifier<AsyncValue<void>> {
  final ProductRequirementRepository _repository;
  final Ref _ref;

  ProductRequirementController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> saveRequirement(ProductRequirementRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.save(request);
      _ref.invalidate(productRequirementListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateRequirement(int id, ProductRequirementRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request);
      _ref.invalidate(productRequirementListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateStatus(int id, String status) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateStatus(id, status);
      _ref.invalidate(productRequirementListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteRequirement(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(productRequirementListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}