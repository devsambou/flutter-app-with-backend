import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_colors.dart';
import 'core/supabase/supabase_config.dart';
import 'data/datasources/movie_local_data_source.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Chargement des variables d'environnement
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ Impossible de charger le fichier .env : $e');
  }

  // 2. Initialisation de la persistance locale Hive
  await Hive.initFlutter();
  await Hive.openBox(MovieLocalDataSourceImpl.trendingBoxName);
  await Hive.openBox(MovieLocalDataSourceImpl.detailsBoxName);

  // 3. Initialisation du client Supabase
  await SupabaseConfig.initialize();

  runApp(const ProviderScope(child: MovieVaultApp()));
}

class MovieVaultApp extends ConsumerWidget {
  const MovieVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'MovieVault',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardColor: AppColors.card,
        fontFamily: 'Roboto',
      ),
    );
  }
}
