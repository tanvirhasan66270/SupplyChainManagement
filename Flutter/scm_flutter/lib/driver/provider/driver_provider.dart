import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/driver/data/driver_repository.dart';
import 'package:scm_flutter/entity/driver_model.dart';

// ১. Driver Repository Provider
final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  return DriverRepository(ref.watch(apiClientProvider));
});

/// ২. The logged-in driver's profile — keyed off the authenticated user's `userId`.
final currentDriverProvider = FutureProvider.autoDispose<DriverResponseModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final role = user.role.toUpperCase();
  if (role != 'DRIVER' && role != 'ROLE_DRIVER') {
    return null;
  }
  try {
    return await ref.watch(driverRepositoryProvider).findByUserId(user.userId);
  } catch (_) {
    return null;
  }
});

/// ৩. Get All Drivers List Provider
final driverListProvider = FutureProvider.autoDispose<List<DriverResponseModel>>((ref) async {
  final repository = ref.watch(driverRepositoryProvider);
  return repository.getAll();
});

/// ৪. Get Single Driver By ID Provider
final singleDriverProvider = FutureProvider.autoDispose.family<DriverResponseModel, int>((ref, driverId) async {
  final repository = ref.watch(driverRepositoryProvider);
  final drivers = await repository.getAll();
  return drivers.firstWhere((d) => d.id == driverId, orElse: () => throw Exception('Driver not found'));
});