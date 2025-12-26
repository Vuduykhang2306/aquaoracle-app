import 'package:flutter/material.dart';
import 'config/app_colors.dart';
import 'config/responsive.dart';
import 'providers/settings_provider.dart';
import 'services/supabase_service.dart';
import 'screens/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void toggleNotifications() {
    setState(() {
      notificationsEnabled = !notificationsEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsProvider(
      isDarkMode: isDarkMode,
      notificationsEnabled: notificationsEnabled,
      onThemeToggle: toggleTheme,
      onNotificationToggle: toggleNotifications,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hong Bang AquaOracle',
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final baseTheme = ThemeData(brightness: Brightness.light);
    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.lightPrimary,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        color: AppColors.lightCard,
        surfaceTintColor: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme).copyWith(
        headlineMedium: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.lightText,
          fontSize: 24,
        ),
        bodyMedium: const TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
        ),
        labelLarge: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final baseTheme = ThemeData(brightness: Brightness.dark);
    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.darkPrimary,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.darkCard,
        surfaceTintColor: AppColors.darkCard,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme).copyWith(
        headlineMedium: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
          fontSize: 24,
        ),
        bodyMedium: const TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
        ),
        labelLarge: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}