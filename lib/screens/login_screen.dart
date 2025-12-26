import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../config/app_colors.dart';
import '../config/responsive.dart';
import '../providers/settings_provider.dart';
import '../services/supabase_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabaseService = SupabaseService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final isAuthenticated = await _supabaseService.authenticateDevice(
        _idController.text.trim(),
        _passwordController.text.trim(),
      );

      if (isAuthenticated && mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, _) => const HomeScreen(),
            transitionsBuilder: (context, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      } else {
        _showErrorDialog(
          "Đăng nhập thất bại",
          "ID ESP hoặc mật khẩu không đúng!",
        );
      }
    } on TimeoutException {
      _showErrorDialog(
        "Lỗi kết nối",
        "Kết nối quá chậm, vui lòng thử lại!",
      );
    } catch (e) {
      _showErrorDialog("Lỗi", "Không thể kết nối: ${e.toString()}");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.lightPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDarkMode = SettingsProvider.of(context)?.isDarkMode ?? false;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.darkBackground, AppColors.darkCard]
                : [AppColors.lightPrimary, AppColors.lightPrimaryDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.w(16)),
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _slideController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: Responsive.w(80),
                        height: Responsive.w(80),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lightPrimary.withOpacity(0.4),
                              blurRadius: Responsive.r(20),
                              spreadRadius: Responsive.r(2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.opacity_outlined,
                          size: Responsive.sp(40),
                          color: AppColors.lightPrimaryDark,
                        ),
                      ),
                      SizedBox(height: Responsive.h(24)),
                      Text(
                        "AquaSense Pro",
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(26),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: Responsive.h(8)),
                      Text(
                        "Đăng nhập để giám sát chất lượng môi trường",
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(14),
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: Responsive.h(32)),
                      Container(
                        padding: EdgeInsets.all(Responsive.w(28)),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColors.darkCard
                              : Colors.white,
                          borderRadius: BorderRadius.circular(Responsive.r(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: Responsive.r(40),
                              spreadRadius: 0,
                              offset: Offset(0, Responsive.h(15)),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text(
                                "Đăng nhập ESP",
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(20),
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                                ),
                              ),
                              SizedBox(height: Responsive.h(24)),
                              _buildTextField(
                                controller: _idController,
                                label: "ESP Device ID",
                                hint: "Nhập ID thiết bị ESP",
                                icon: Icons.developer_board_outlined,
                                isDarkMode: isDarkMode,
                              ),
                              SizedBox(height: Responsive.h(16)),
                              _buildTextField(
                                controller: _passwordController,
                                label: "Mật khẩu ESP",
                                hint: "Nhập mật khẩu thiết bị",
                                icon: Icons.lock_outline,
                                isPassword: true,
                                isDarkMode: isDarkMode,
                              ),
                              SizedBox(height: Responsive.h(24)),
                              _buildLoginButton(isDarkMode),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required bool isDarkMode,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: TextStyle(
        color: isDarkMode ? AppColors.darkText : AppColors.lightText,
        fontSize: Responsive.sp(14),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: AppColors.lightPrimary,
          size: Responsive.sp(20),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.lightPrimary,
                  size: Responsive.sp(20),
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: isDarkMode
            ? AppColors.darkBackground.withOpacity(0.5)
            : AppColors.lightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.r(12)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.r(12)),
          borderSide: BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
        labelStyle: TextStyle(
          color: isDarkMode
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          fontSize: Responsive.sp(14),
        ),
        hintStyle: TextStyle(
          color: isDarkMode
              ? AppColors.darkTextSecondary.withOpacity(0.5)
              : AppColors.lightTextSecondary.withOpacity(0.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return isPassword
              ? "Vui lòng nhập mật khẩu"
              : "Vui lòng nhập ESP ID";
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: Responsive.h(48),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.lightPrimary, AppColors.lightPrimaryDark],
        ),
        borderRadius: BorderRadius.circular(Responsive.r(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightPrimary.withOpacity(0.3),
            blurRadius: Responsive.r(20),
            offset: Offset(0, Responsive.h(10)),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.r(16)),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: Responsive.w(20),
                height: Responsive.w(20),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                "Đăng nhập",
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(14),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}