import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/grn_model.dart';
import 'package:scm_flutter/logistics_officer/data/good_received_note_repository.dart';

// ১. Repository Provider
final goodReceivedNoteRepositoryProvider = Provider<GoodReceivedNoteRepository>((ref) {
  return GoodReceivedNoteRepository(ref.watch(apiClientProvider));
});

// ২. List Provider
final goodReceivedNoteListProvider = FutureProvider.autoDispose<List<GoodsReceivedNoteResponseModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(goodReceivedNoteRepositoryProvider);
  try {
    return await repo.findAll();
  } catch (_) {
    return [];
  }
});

// ৩. Controller / Notifier (Save, Update, Delete)
final goodReceivedNoteControllerProvider = StateNotifierProvider<GoodReceivedNoteController, AsyncValue<void>>((ref) {
  final repo = ref.watch(goodReceivedNoteRepositoryProvider);
  return GoodReceivedNoteController(repo, ref);
});

class GoodReceivedNoteController extends StateNotifier<AsyncValue<void>> {
  final GoodReceivedNoteRepository _repository;
  final Ref _ref;

  GoodReceivedNoteController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> saveGRN(GoodsReceivedNoteRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.save(request);
      _ref.invalidate(goodReceivedNoteListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateGRN(int id, GoodsReceivedNoteRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request);
      _ref.invalidate(goodReceivedNoteListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteGRN(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(goodReceivedNoteListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}