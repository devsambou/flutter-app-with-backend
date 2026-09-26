import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/error/exceptions.dart';
import '../../domain/repositories/auth_repository_interface.dart';

/// Implémentation concrète de l'authentification s'appuyant sur Supabase Auth.
/// Supabase gère nativement le stockage sécurisé du JWT ainsi que le refresh token.
class AuthRepository implements AuthRepositoryInterface {
  final SupabaseClient supabaseClient;

  AuthRepository(this.supabaseClient);

  @override
  Session? get currentSession => supabaseClient.auth.currentSession;

  @override
  User? get currentUser => supabaseClient.auth.currentUser;

  @override
  bool get isAuthenticated => currentSession != null;

  @override
  Stream<AuthState> get authStateChanges =>
      supabaseClient.auth.onAuthStateChange;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw AuthExceptionApp(_mapAuthErrorMessage(e.message));
    } catch (e) {
      throw AuthExceptionApp('Erreur inattendue lors de l\'inscription : $e');
    }
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw AuthExceptionApp(_mapAuthErrorMessage(e.message));
    } catch (e) {
      throw AuthExceptionApp('Erreur inattendue lors de la connexion : $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw AuthExceptionApp('Erreur lors de la déconnexion : $e');
    }
  }

  String _mapAuthErrorMessage(String rawMessage) {
    final lower = rawMessage.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials')) {
      return 'Email ou mot de passe incorrect.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('already exists')) {
      return 'Un compte existe déjà avec cette adresse email.';
    }
    if (lower.contains('password should be at least')) {
      return 'Le mot de passe doit comporter au moins 6 caractères.';
    }
    if (lower.contains('email rate limit exceeded')) {
      return 'Trop de tentatives. Veuillez patienter un instant.';
    }
    return rawMessage;
  }
}
