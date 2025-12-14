import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../config/responsive.dart';
import '../models/water_quality.dart';

class HistoryList extends StatelessWidget {
  final List<WaterQuality> historyData;
  final bool isDarkMode;

  const HistoryList({
    super.key,
    required this.historyData,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    if (historyData.isEmpty) {
      return Card(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(Responsive.w(24)),
            child: Text(
              "Không có dữ liệu lịch sử.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final recentHistory = historyData.take(15).toList();

    return Card(
      child: ListView.separated(
        itemCount: recentHistory.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final item = recentHistory[index];
          final formattedDate = DateFormat('HH:mm - dd/MM/yyyy').format(item.createdAt.toLocal());

          return ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: Responsive.w(16),
              vertical: Responsive.h(4),
            ),
            leading: CircleAvatar(
              backgroundColor: isDarkMode
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
              child: Icon(
                Icons.history,
                size: Responsive.sp(20),
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            title: Text(
              "TDS: ${item.tds.toStringAsFixed(1)} - Đục: ${item.turbidity.toStringAsFixed(2)} - pH: ${item.ph.toStringAsFixed(1)} - Temp: ${item.temperature.toStringAsFixed(1)}°C",
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(13),
                fontWeight: FontWeight.w500,
                color: isDarkMode ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            subtitle: Text(
              formattedDate,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(12),
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 1,
            thickness: 1,
            color: isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            indent: Responsive.w(16),
            endIndent: Responsive.w(16),
          );
        },
      ),
    );
  }
}