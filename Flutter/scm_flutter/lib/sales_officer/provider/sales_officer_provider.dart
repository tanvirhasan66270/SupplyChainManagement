import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/sales_officer/data/sales_officer_repository.dart';
import 'package:scm_flutter/entity/sales_officer_model.dart';

final salesOfficerRepositoryProvider = Provider<SalesOfficerRepository>((ref) {
  return SalesOfficerRepository(ref.watch(apiClientProvider));
});

final salesOfficerListProvider = FutureProvider.autoDispose<List<SalesOfficerResponseDTO>>((ref) async {
  final repo = ref.watch(salesOfficerRepositoryProvider);
  return await repo.getAll();
});

final currentSalesOfficerProvider = FutureProvider.autoDispose<SalesOfficerResponseDTO?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final role = user.role.toUpperCase();
  if (!role.contains('SALES')) return null;
  try {
    return await ref.watch(salesOfficerRepositoryProvider).findByUserId(user.userId);
  } catch (_) {
    return null;
  }
});
