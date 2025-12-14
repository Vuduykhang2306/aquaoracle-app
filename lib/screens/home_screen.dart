import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../config/app_colors.dart';
import '../config/app_config.dart';
import '../config/responsive.dart';
import '../models/water_quality.dart';
import '../services/supabase_service.dart';
import '../services/ai_analysis_service.dart';
import '../providers/settings_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/history_list.dart';
import '../widgets/chart_widgets.dart';
import 'ml_screen.dart';
import 'history_screen.dart';
import 'edit_iot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _supabaseService = SupabaseService();
  final _aiService = AIAnalysisService();
  final TextEditingController _chatController = TextEditingController();
  
  WaterQuality? latestData;
  List<WaterQuality> historyData = [];
  String aiAnalysis = "";
  List<Map<String, String>> chatMessages = [];
  bool isLoading = true;
  bool isLoadingAI = false;
  bool isSendingMessage = false;
  String errorMessage = '';
  Timer? _refreshTimer;
  int _selectedNavIndex = 0;

  late AnimationController _floatingController;
  late AnimationController _fadeController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    fetchData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _floatingController.dispose();
    _fadeController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      Duration(seconds: AppConfig.autoRefreshSeconds),
      (timer) {
        if (mounted) fetchData();
      },
    );
  }

  Future<void> fetchData() async {
    try {
      setState(() => errorMessage = '');

      final latest = await _supabaseService.getLatestWaterQuality();
      final history = await _supabaseService.getWaterQualityHistory(
        limit: AppConfig.historyLimit,
      );

      if (mounted) {
        setState(() {
          latestData = latest;
          historyData = history;
          isLoading = false;
        });
        _fadeController.forward();
        _generateAIAnalysis();
      }
    } catch (e) {
      _handleError("Lỗi kết nối: ${e.toString()}");
    }
  }

  Future<void> _generateAIAnalysis() async {
    if (latestData == null || historyData.isEmpty) return;
    
    setState(() => isLoadingAI = true);

    try {
      final analysis = await _aiService.analyzeWaterQuality(
        latestData!,
        historyData,
      );
      
      if (mounted) {
        setState(() {
          aiAnalysis = analysis;
          isLoadingAI = false;
          if (chatMessages.isEmpty) {
            chatMessages.add({
              'role': 'ai',
              'message': analysis,
            });
          }
        });
      }
    } catch (e) {
      debugPrint("AI Analysis Error: $e");
      if (mounted) {
        setState(() {
          aiAnalysis = "Không thể kết nối đến AI service.";
          isLoadingAI = false;
        });
      }
    }
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        isLoading = false;
        errorMessage = message;
      });
    }
  }

  Future<void> _sendChatMessage() async {
    if (_chatController.text.trim().isEmpty) return;

    final userMessage = _chatController.text.trim();
    setState(() {
      chatMessages.add({
        'role': 'user',
        'message': userMessage,
      });
      isSendingMessage = true;
    });

    _chatController.clear();

    // Simulate AI response (in real app, call AI service with context)
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        chatMessages.add({
          'role': 'ai',
          'message': 'Cảm ơn câu hỏi của bạn về "$userMessage". Dựa trên dữ liệu hiện tại, tôi khuyên bạn nên theo dõi các chỉ số TDS và độ đục thường xuyên.',
        });
        isSendingMessage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDarkMode = SettingsProvider.of(context)?.isDarkMode ?? false;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchData,
          color: AppColors.lightPrimary,
          backgroundColor: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          child: _buildContent(isDarkMode),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDarkMode),
    );
  }

  Widget _buildBottomNav(bool isDarkMode) {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: (index) {
        setState(() => _selectedNavIndex = index);
        
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MLScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditIoTScreen()),
          );
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
      selectedItemColor: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
      unselectedItemColor: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      selectedLabelStyle: GoogleFonts.poppins(fontSize: Responsive.sp(11)),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: Responsive.sp(11)),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology_outlined),
          activeIcon: Icon(Icons.psychology),
          label: 'ML',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history),
          label: 'Lịch sử',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Cài đặt',
        ),
      ],
    );
  }

  Widget _buildContent(bool isDarkMode) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: Responsive.w(40),
              height: Responsive.w(40),
              child: const CircularProgressIndicator(
                color: AppColors.lightPrimary,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: Responsive.h(16)),
            Text(
              "Đang tải dữ liệu...",
              style: GoogleFonts.poppins(
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: Responsive.sp(14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Responsive.w(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.red.shade300,
                size: Responsive.sp(50),
              ),
              SizedBox(height: Responsive.h(16)),
              Text(
                "Lỗi kết nối",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: 20),
              ),
              SizedBox(height: Responsive.h(8)),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: Responsive.h(24)),
              ElevatedButton(
                onPressed: () {
                  setState(() => isLoading = true);
                  fetchData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Thử lại",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDarkMode),
                  if (latestData != null) _buildQuickStats(isDarkMode),
                  SizedBox(height: Responsive.h(16)),
                  _buildParameterButtons(isDarkMode),
                  SizedBox(height: Responsive.h(16)),
                  _buildSectionTitle(
                    isDarkMode,
                    "Chatbox AI tương tác",
                    Icons.chat_bubble_outline,
                  ),
                  SizedBox(height: Responsive.h(8)),
                  _buildAIChatbox(isDarkMode),
                  SizedBox(height: Responsive.h(16)),
                  _buildSectionTitle(
                    isDarkMode,
                    "Biểu đồ trạng thái",
                    Icons.timeline_outlined,
                  ),
                  SizedBox(height: Responsive.h(8)),
                  WaterQualityChart(
                    historyData: historyData,
                    isDarkMode: isDarkMode,
                  ),
                  SizedBox(height: Responsive.h(16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle(
                        isDarkMode,
                        "Dữ liệu gần đây",
                        Icons.history_outlined,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Xem tất cả',
                          style: GoogleFonts.poppins(
                            color: isDarkMode
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                            fontSize: Responsive.sp(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(8)),
                  HistoryList(
                    historyData: historyData,
                    isDarkMode: isDarkMode,
                  ),
                  SizedBox(height: Responsive.h(80)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParameterButtons(bool isDarkMode) {
    if (latestData == null) return const SizedBox.shrink();

    final data = latestData!;

    return Row(
      children: [
        Expanded(
          child: _buildParameterButton(
            isDarkMode,
            'Tốc',
            '${data.tds.toStringAsFixed(0)}',
            'ppm',
            Icons.science_outlined,
            data.tds < 300 ? Colors.green : (data.tds < 500 ? Colors.orange : Colors.red),
          ),
        ),
        SizedBox(width: Responsive.w(8)),
        Expanded(
          child: _buildParameterButton(
            isDarkMode,
            'Độc',
            '${data.turbidity.toStringAsFixed(1)}',
            'NTU',
            Icons.visibility_outlined,
            data.turbidity < 2 ? Colors.green : (data.turbidity < 5 ? Colors.orange : Colors.red),
          ),
        ),
        SizedBox(width: Responsive.w(8)),
        Expanded(
          child: _buildParameterButton(
            isDarkMode,
            'pH',
            data.ph.toStringAsFixed(1),
            '',
            Icons.water_drop_outlined,
            (data.ph >= 6.5 && data.ph <= 8.5) ? Colors.green : Colors.red,
          ),
        ),
        SizedBox(width: Responsive.w(8)),
        Expanded(
          child: _buildParameterButton(
            isDarkMode,
            'Nhiệt độ',
            '${data.temperature.toStringAsFixed(0)}',
            '°C',
            Icons.thermostat_outlined,
            data.temperature < 35 ? Colors.green : (data.temperature < 45 ? Colors.orange : Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildParameterButton(
    bool isDarkMode,
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Responsive.h(12),
        horizontal: Responsive.w(8),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: Responsive.sp(20)),
          SizedBox(height: Responsive.h(4)),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(10),
              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: Responsive.h(2)),
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(14),
                fontWeight: FontWeight.w700,
                color: color,
              ),
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: unit.isNotEmpty ? ' $unit' : '',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIChatbox(bool isDarkMode) {
    return Card(
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(maxHeight: Responsive.h(300)),
            child: ListView.builder(
              padding: EdgeInsets.all(Responsive.w(12)),
              shrinkWrap: true,
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final msg = chatMessages[index];
                final isAI = msg['role'] == 'ai';
                
                return Padding(
                  padding: EdgeInsets.only(bottom: Responsive.h(12)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAI) ...[
                        CircleAvatar(
                          radius: Responsive.sp(16),
                          backgroundColor: isDarkMode
                              ? AppColors.darkPrimary.withOpacity(0.1)
                              : AppColors.lightPrimary.withOpacity(0.1),
                          child: Icon(
                            Icons.auto_awesome,
                            color: isDarkMode
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                            size: Responsive.sp(16),
                          ),
                        ),
                        SizedBox(width: Responsive.w(8)),
                      ],
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(Responsive.w(12)),
                          decoration: BoxDecoration(
                            color: isAI
                                ? (isDarkMode
                                    ? AppColors.darkPrimary.withOpacity(0.1)
                                    : AppColors.lightPrimary.withOpacity(0.1))
                                : (isDarkMode
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg['message'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(13),
                              color: isDarkMode
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      if (!isAI) ...[
                        SizedBox(width: Responsive.w(8)),
                        CircleAvatar(
                          radius: Responsive.sp(16),
                          backgroundColor: isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                          child: Icon(
                            Icons.person,
                            color: isDarkMode ? Colors.white : Colors.black87,
                            size: Responsive.sp(16),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
          Padding(
            padding: EdgeInsets.all(Responsive.w(12)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Hỏi AI về chất lượng nước...',
                      hintStyle: GoogleFonts.poppins(fontSize: Responsive.sp(13)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(16),
                        vertical: Responsive.h(10),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: Responsive.sp(13)),
                    onSubmitted: (_) => _sendChatMessage(),
                  ),
                ),
                SizedBox(width: Responsive.w(8)),
                CircleAvatar(
                  backgroundColor: isDarkMode
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                  child: IconButton(
                    icon: Icon(
                      isSendingMessage ? Icons.hourglass_empty : Icons.send,
                      color: Colors.white,
                      size: Responsive.sp(18),
                    ),
                    onPressed: isSendingMessage ? null : _sendChatMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(bool isDarkMode, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: Responsive.sp(18),
          color: isDarkMode
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
        SizedBox(width: Responsive.w(8)),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(16),
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    final settings = SettingsProvider.of(context);
    
    return Container(
      padding: EdgeInsets.only(
        top: Responsive.h(16),
        bottom: Responsive.h(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ESP-32 Connect",
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(12),
                  color: isDarkMode
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Responsive.h(4)),
              Text(
                "AquaOracle Pro",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          IconButton(
            onPressed: settings?.onThemeToggle,
            icon: Icon(
              isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              color: isDarkMode
                  ? Colors.yellow.shade700
                  : Colors.orange.shade400,
              size: Responsive.sp(24),
            ),
            tooltip: isDarkMode ? "Chuyển sang Sáng" : "Chuyển sang Tối",
          )
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDarkMode) {
    final data = latestData!;
    final drinkabilityStatus = _aiService.getDrinkabilityStatus(data);

    Color getTdsColor(double val) {
      if (val < 300) return Colors.green;
      if (val < 500) return Colors.orange;
      return Colors.red;
    }
    
    Color getTurbidityColor(double val) {
      if (val < 2) return Colors.green;
      if (val < 5) return Colors.orange;
      return Colors.red;
    }

    Color getPhColor(double val) {
      if (val >= 6.5 && val <= 8.5) return Colors.green;
      return Colors.red;
    }

    Color getTempColor(double val) {
      if (val < 35) return Colors.green;
      if (val < 45) return Colors.orange;
      return Colors.red;
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: "TDS (Tổng chất rắn)",
                value: data.tds.toStringAsFixed(1),
                unit: "ppm",
                icon: Icons.science_outlined,
                iconColor: getTdsColor(data.tds),
              ),
            ),
            SizedBox(width: Responsive.w(16)),
            Expanded(
              child: StatCard(
                title: "Độ đục",
                value: data.turbidity.toStringAsFixed(2),
                unit: "NTU",
                icon: Icons.visibility_outlined,
                iconColor: getTurbidityColor(data.turbidity),
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(16)),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: "Độ pH",
                value: data.ph.toStringAsFixed(1),
                unit: "",
                icon: Icons.water_drop_outlined,
                iconColor: getPhColor(data.ph),
              ),
            ),
            SizedBox(width: Responsive.w(16)),
            Expanded(
              child: StatCard(
                title: "Nhiệt độ",
                value: data.temperature.toStringAsFixed(1),
                unit: "°C",
                icon: Icons.thermostat_outlined,
                iconColor: getTempColor(data.temperature),
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(16)),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: "Trạng thái nước uống",
                value: drinkabilityStatus,
                unit: "",
                icon: drinkabilityStatus == "An toàn để uống"
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                iconColor: drinkabilityStatus == "An toàn để uống"
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}