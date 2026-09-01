
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scm_flutter/auth/authRepository.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/loginModel.dart';


final authRepositoryProvider = Provider<AuthRepository>((ref) {

  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  );
});


class AuthController extends StateNotifier<AsyncValue<LoginResponse?>>{

  AuthController(this._ref) : super(const AsyncValue.loading()) {
    _restoreSession();
  }

  final Ref _ref;

  Future<void> _restoreSession() async {
    final storage = _ref.read(storageServiceProvider);
    final user = await storage.getUser();
    final token = await storage.getToken();
    if (token == null || token.trim().isEmpty || user == null) {
      state = const AsyncValue.data(null);
      return;
    }
    state = AsyncValue.data(user);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(authRepositoryProvider);
      final res = await repo.login(
        LoginRequest(email: email, password: password),
      );
      state = AsyncValue.data(res);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }


}
final authControllerProvider =
StateNotifierProvider<AuthController, AsyncValue<LoginResponse?>>((ref) {
  return AuthController(ref);
});

/// Convenience: current user, or null. Returns null while loading too, so
/// only use this where a brief null flash during startup is acceptable
/// (e.g. UI that already handles a splash/loading state via the router).
final currentUserProvider = Provider<LoginResponse?>((ref) {
  return ref.watch(authControllerProvider).value;
});
