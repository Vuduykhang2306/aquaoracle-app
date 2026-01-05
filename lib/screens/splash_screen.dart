import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../config/app_colors.dart';
import '../config/responsive.dart';
import '../providers/settings_provider.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoScale;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 2500));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDarkMode = SettingsProvider.of(context)?.isDarkMode ?? false;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeOut,
        child: Container(
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? AppColors.darkOceanGradient
                : AppColors.oceanGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: Responsive.w(120),
                        height: Responsive.w(120),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: Responsive.r(30),
                              spreadRadius: Responsive.r(5),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(Responsive.w(20)),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: Responsive.h(24)),
                Text(
                  "Hong Bang AquaOracle",
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(22),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: Responsive.h(12)),
                Text(
                  "Hệ thống giám sát chất lượng môi trường thủy sản",
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(14),
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: Responsive.h(40)),
                Text(
                  "Developed by Vũ Duy Khang",
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(14),
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}