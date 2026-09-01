import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/daily_report_model.dart';
import 'package:scm_flutter/logistics_officer/data/daily_report_repository.dart';

// ১. Repository Provider
final dailyReportRepositoryProvider = Provider<DailyReportRepository>((ref) {
  return DailyReportRepository(ref.watch(apiClientProvider));
});

// ২. List Provider
final dailyReportListProvider = FutureProvider.autoDispose<List<DailyReportResponseModel>>((ref) async {
  final repo = ref.watch(dailyReportRepositoryProvider);
  return await repo.findAll();
});

// ৩. Controller / Notifier (Create, Update, Approve, Delete)
final dailyReportControllerProvider = StateNotifierProvider<DailyReportController, AsyncValue<void>>((ref) {
  final repo = ref.watch(dailyReportRepositoryProvider);
  return DailyReportController(repo, ref);
});

class DailyReportController extends StateNotifier<AsyncValue<void>> {
  final DailyReportRepository _repository;
  final Ref _ref;

  DailyReportController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> createReport(DailyReportRequestModel request, XFile? attachment) async {
    state = const AsyncValue.loading();
    try {
      await _repository.create(request, attachment);
      _ref.invalidate(dailyReportListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateReport(int id, DailyReportRequestModel request, XFile? attachment) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, request, attachment);
      _ref.invalidate(dailyReportListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> approveReport(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.approve(id);
      _ref.invalidate(dailyReportListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteReport(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      _ref.invalidate(dailyReportListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}