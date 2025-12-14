import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../config/responsive.dart';
import '../models/water_quality.dart';
import '../services/supabase_service.dart';
import '../providers/settings_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _supabaseService = SupabaseService();
  List<WaterQuality> historyData = [];
  bool isLoading = true;
  String errorMessage = '';
  String filterType = 'all';

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final data = await _supabaseService.getWaterQualityHistory(limit: 200);

      if (mounted) {
        setState(() {
          historyData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Lỗi kết nối: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  List<WaterQuality> get filteredData {
    if (filterType == 'all') return historyData;
    
    return historyData.where((item) {
      final isSafe = item.tds <= 500 &&
          item.turbidity <= 5 &&
          item.ph >= 6.5 &&
          item.ph <= 8.5;
      
      if (filterType == 'safe') return isSafe;
      if (filterType == 'unsafe') return !isSafe;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDarkMode = SettingsProvider.of(context)?.isDarkMode ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? AppColors.darkText : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lịch sử đo đạc',
          style: GoogleFonts.poppins(
            color: isDarkMode ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHistory,
            color: isDarkMode ? AppColors.darkText : AppColors.lightText,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterChips(isDarkMode),
            Expanded(
              child: _buildContent(isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(16),
        vertical: Responsive.h(12),
      ),
      child: Row(
        children: [
          _buildFilterChip(isDarkMode, 'Tất cả', 'all'),
          SizedBox(width: Responsive.w(8)),
          _buildFilterChip(isDarkMode, 'An toàn', 'safe'),
          SizedBox(width: Responsive.w(8)),
          _buildFilterChip(isDarkMode, 'Không an toàn', 'unsafe'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(bool isDarkMode, String label, String value) {
    final isSelected = filterType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          filterType = value;
        });
      },
      selectedColor: isDarkMode
          ? AppColors.darkPrimary.withOpacity(0.3)
          : AppColors.lightPrimary.withOpacity(0.2),
      labelStyle: GoogleFonts.poppins(
        color: isSelected
            ? (isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary)
            : (isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: Responsive.sp(12),
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
            ),
            SizedBox(height: Responsive.h(16)),
            Text(
              'Đang tải lịch sử...',
              style: GoogleFonts.poppins(
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
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
                Icons.error_outline,
                size: Responsive.sp(50),
                color: Colors.red.shade300,
              ),
              SizedBox(height: Responsive.h(16)),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              SizedBox(height: Responsive.h(16)),
              ElevatedButton(
                onPressed: _fetchHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                ),
                child: Text(
                  'Thử lại',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = filteredData;

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'Không có dữ liệu',
          style: GoogleFonts.poppins(
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
      child: ListView.builder(
        padding: EdgeInsets.all(Responsive.w(16)),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return _buildHistoryItem(isDarkMode, filtered[index]);
        },
      ),
    );
  }

  Widget _buildHistoryItem(bool isDarkMode, WaterQuality item) {
    final isSafe = item.tds <= 500 &&
        item.turbidity <= 5 &&
        item.ph >= 6.5 &&
        item.ph <= 8.5;

    final statusColor = isSafe ? Colors.green : Colors.red;
    final statusText = isSafe ? 'An toàn' : 'Không an toàn';

    return Card(
      margin: EdgeInsets.only(bottom: Responsive.h(12)),
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isSafe ? Icons.check_circle : Icons.cancel,
                      color: statusColor,
                      size: Responsive.sp(20),
                    ),
                    SizedBox(width: Responsive.w(8)),
                    Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: Responsive.sp(14),
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt),
                  style: GoogleFonts.poppins(
                    color: isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: Responsive.sp(12),
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildParameter(isDarkMode, 'TDS', '${item.tds.toStringAsFixed(1)} ppm'),
                _buildParameter(isDarkMode, 'Độ đục', '${item.turbidity.toStringAsFixed(2)} NTU'),
              ],
            ),
            SizedBox(height: Responsive.h(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildParameter(isDarkMode, 'pH', item.ph.toStringAsFixed(1)),
                _buildParameter(isDarkMode, 'Nhiệt độ', '${item.temperature.toStringAsFixed(1)}°C'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameter(bool isDarkMode, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(11),
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(14),
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ],
    );
  }
}