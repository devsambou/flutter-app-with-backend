import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';

/// Client Dio dédié exclusivement aux requêtes vers l'API TMDB.
/// Il injecte la clé API TMDB automatiquement via un intercepteur
/// et isole totalement ces requêtes de l'authentification Supabase.
class TmdbDioClient {
  late final Dio dio;

  TmdbDioClient({Dio? customDio}) {
    dio =
        customDio ??
        Dio(
          BaseOptions(
            baseUrl: ApiConstants.tmdbBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Lecture sécurisée des variables d'environnement
          final apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
          final bearerToken = dotenv.env['TMDB_BEARER_TOKEN'] ?? '';

          if (bearerToken.isNotEmpty &&
              bearerToken != 'placeholder_tmdb_bearer_token') {
            options.headers['Authorization'] = 'Bearer $bearerToken';
          } else if (apiKey.isNotEmpty) {
            options.queryParameters['api_key'] = apiKey;
          }

          // Options de langue française par défaut pour TMDB
          options.queryParameters.putIfAbsent('language', () => 'fr-FR');

          return handler.next(options);
        },
        onError: (DioException error, handler) {
          final statusCode = error.response?.statusCode;
          String message = 'Une erreur réseau est survenue';

          switch (error.type) {
            case DioExceptionType.connectionTimeout:
            case DioExceptionType.sendTimeout:
            case DioExceptionType.receiveTimeout:
              message =
                  'Délai d\'attente dépassé lors de la communication avec TMDB';
              break;
            case DioExceptionType.badResponse:
              if (statusCode == 401) {
                message = 'Clé API TMDB invalide ou non autorisée';
              } else if (statusCode == 404) {
                message = 'Ressource cinématographique introuvable';
              } else if (statusCode != null && statusCode >= 500) {
                message =
                    'Le service TMDB rencontre des difficultés techniques';
              } else {
                message =
                    error.response?.data?['status_message'] ??
                    'Erreur API TMDB ($statusCode)';
              }
              break;
            case DioExceptionType.connectionError:
              message =
                  'Impossible de joindre les serveurs TMDB (vérifiez votre connexion)';
              break;
            default:
              message = error.message ?? 'Erreur inconnue';
          }

          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: ServerException(message, statusCode),
            ),
          );
        },
      ),
    );
  }
}
