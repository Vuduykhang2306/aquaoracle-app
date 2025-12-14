import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../config/responsive.dart';
import '../models/water_quality.dart';

class WaterQualityChart extends StatelessWidget {
  final List<WaterQuality> historyData;
  final bool isDarkMode;

  const WaterQualityChart({
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
              "Không đủ dữ liệu để vẽ biểu đồ.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final reversedHistory = historyData.reversed.toList();
    
    List<FlSpot> tdsSpots = [];
    List<FlSpot> turbiditySpots = [];

    for (int i = 0; i < reversedHistory.length; i++) {
      final item = reversedHistory[i];
      tdsSpots.add(FlSpot(i.toDouble(), item.tds));
      turbiditySpots.add(FlSpot(i.toDouble(), item.turbidity));
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(16)).copyWith(right: Responsive.w(24)),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDarkMode
                            ? AppColors.darkCard
                            : Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.poppins(
                              color: isDarkMode
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              fontSize: Responsive.sp(10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: isDarkMode
                          ? AppColors.darkCard
                          : Colors.grey.shade200,
                    ),
                  ),
                  minY: 0,
                  lineBarsData: [
                    _buildLineBarData(tdsSpots, AppColors.lightPrimary),
                    _buildLineBarData(turbiditySpots, Colors.teal),
                  ],
                ),
              ),
            ),
            SizedBox(height: Responsive.h(16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(AppColors.lightPrimary, "TDS (ppm)", context),
                SizedBox(width: Responsive.w(24)),
                _buildLegendItem(Colors.teal, "Độ đục (NTU)", context),
              ],
            )
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLineBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text, BuildContext context) {
    return Row(
      children: [
        Container(
          width: Responsive.w(12),
          height: Responsive.w(12),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: Responsive.w(6)),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(12),
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}