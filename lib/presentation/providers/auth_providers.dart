import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_config.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/repositories/auth_repository_interface.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseConfig.client;
});

final authRepositoryProvider = Provider<AuthRepositoryInterface>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});

final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateStreamProvider);
  final repo = ref.watch(authRepositoryProvider);
  return repo.currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

/// État de chargement / erreur pour les actions d'authentification (Riverpod 2.x StateNotifier)
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepositoryInterface _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  Future<bool> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signIn(email: email, password: password);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signUp(email: email, password: password);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider.autoDispose<AuthController, AsyncValue<void>>((ref) {
      final repo = ref.watch(authRepositoryProvider);
      return AuthController(repo);
    });
