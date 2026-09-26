import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepositoryInterface {
  /// Session actuelle
  Session? get currentSession;

  /// Utilisateur actuellement connecté
  User? get currentUser;

  /// Vérifie si l'utilisateur est authentifié
  bool get isAuthenticated;

  /// Flux réactif des changements d'état d'authentification
  Stream<AuthState> get authStateChanges;

  /// Inscription d'un nouvel utilisateur
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  });

  /// Connexion avec identifiants existants
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  /// Déconnexion de l'utilisateur
  Future<void> signOut();

  /// Renouvelle explicitement la session JWT auprès de Supabase.
  Future<Session?> refreshSession();
}
