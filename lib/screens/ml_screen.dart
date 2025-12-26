import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/app_colors.dart';
import '../config/responsive.dart';
import '../providers/settings_provider.dart';

class MLScreen extends StatefulWidget {
  const MLScreen({super.key});

  @override
  State<MLScreen> createState() => _MLScreenState();
}

class _MLScreenState extends State<MLScreen> {
  bool isTraining = false;
  double accuracy = 0.0;
  String selectedModel = 'XGBoost';
  
  final List<String> models = ['XGBoost'];
  final List<double> featureImportance = [0.35, 0.28, 0.22, 0.15];
  final List<String> featureNames = ['TDS', 'Độ đục', 'pH', 'Nhiệt độ'];

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
          'ML Dashboard',
          style: GoogleFonts.poppins(
            color: isDarkMode ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.w(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModelSelector(isDarkMode),
              SizedBox(height: Responsive.h(20)),
              _buildTrainingCard(isDarkMode),
              SizedBox(height: Responsive.h(20)),
              _buildMetricsGrid(isDarkMode),
              SizedBox(height: Responsive.h(20)),
              _buildFeatureImportanceChart(isDarkMode),
              SizedBox(height: Responsive.h(20)),
              _buildConfusionMatrix(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelSelector(bool isDarkMode) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn mô hình ML',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(16),
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            SizedBox(height: Responsive.h(12)),
            Wrap(
              spacing: Responsive.w(8),
              runSpacing: Responsive.h(8),
              children: models.map((model) {
                final isSelected = model == selectedModel;
                return ChoiceChip(
                  label: Text(model),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => selectedModel = model);
                  },
                  selectedColor: isDarkMode
                      ? AppColors.darkPrimary.withOpacity(0.3)
                      : AppColors.lightPrimary.withOpacity(0.2),
                  labelStyle: GoogleFonts.poppins(
                    color: isSelected
                        ? (isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary)
                        : (isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingCard(bool isDarkMode) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Huấn luyện mô hình',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(16),
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    SizedBox(height: Responsive.h(4)),
                    Text(
                      isTraining ? 'Đang huấn luyện...' : 'Sẵn sàng',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(12),
                        color: isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: isTraining ? null : _startTraining,
                  icon: Icon(
                    isTraining ? Icons.hourglass_empty : Icons.play_arrow,
                    size: Responsive.sp(18),
                  ),
                  label: Text(
                    isTraining ? 'Đang chạy' : 'Bắt đầu',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            if (isTraining) ...[
              SizedBox(height: Responsive.h(16)),
              LinearProgressIndicator(
                backgroundColor: isDarkMode
                    ? AppColors.darkCard
                    : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hiệu suất mô hình',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(16),
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        SizedBox(height: Responsive.h(12)),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                isDarkMode,
                'Accuracy',
                '${(accuracy * 100).toStringAsFixed(1)}%',
                Icons.check_circle_outline,
                Colors.green,
              ),
            ),
            SizedBox(width: Responsive.w(12)),
            Expanded(
              child: _buildMetricCard(
                isDarkMode,
                'Precision',
                '${((accuracy - 0.02) * 100).toStringAsFixed(1)}%',
                Icons.grain,
                Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(12)),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                isDarkMode,
                'Recall',
                '${((accuracy - 0.01) * 100).toStringAsFixed(1)}%',
                Icons.restore_outlined,
                Colors.orange,
              ),
            ),
            SizedBox(width: Responsive.w(12)),
            Expanded(
              child: _buildMetricCard(
                isDarkMode,
                'F1-Score',
                '${((accuracy - 0.015) * 100).toStringAsFixed(1)}%',
                Icons.show_chart_outlined,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    bool isDarkMode,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: Responsive.sp(20)),
            SizedBox(height: Responsive.h(8)),
            Text(
              title,
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
                fontSize: Responsive.sp(18),
                fontWeight: FontWeight.w700,
                color: isDarkMode ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureImportanceChart(bool isDarkMode) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tầm quan trọng của đặc trưng',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(16),
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            SizedBox(height: Responsive.h(16)),
            SizedBox(
              height: Responsive.h(200),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 0.4,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < featureNames.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: Responsive.h(8)),
                              child: Text(
                                featureNames[index],
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(10),
                                  color: isDarkMode
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: Responsive.w(40),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(10),
                              color: isDarkMode
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 0.1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    featureImportance.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: featureImportance[index],
                          color: isDarkMode
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                          width: Responsive.w(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfusionMatrix(bool isDarkMode) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ma trận nhầm lẫn',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(16),
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            SizedBox(height: Responsive.h(16)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.3),
                ),
                columnWidths: {
                  0: FixedColumnWidth(Responsive.w(90)),
                  1: FixedColumnWidth(Responsive.w(90)),
                  2: FixedColumnWidth(Responsive.w(110)),
                },
                children: [
                  TableRow(
                    children: [
                      _buildMatrixCell(isDarkMode, '', isHeader: true),
                      _buildMatrixCell(isDarkMode, 'An toàn', isHeader: true),
                      _buildMatrixCell(isDarkMode, 'Không an toàn', isHeader: true),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildMatrixCell(isDarkMode, 'An toàn', isHeader: true),
                      _buildMatrixCell(isDarkMode, '142', value: 142),
                      _buildMatrixCell(isDarkMode, '8', value: 8),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildMatrixCell(isDarkMode, 'Không an toàn', isHeader: true),
                      _buildMatrixCell(isDarkMode, '5', value: 5),
                      _buildMatrixCell(isDarkMode, '45', value: 45),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixCell(bool isDarkMode, String text,
      {bool isHeader = false, int? value}) {
    Color? bgColor;
    if (value != null) {
      if (value > 100) {
        bgColor = Colors.green.withOpacity(0.2);
      } else if (value > 40) {
        bgColor = Colors.green.withOpacity(0.15);
      } else if (value > 5) {
        bgColor = Colors.orange.withOpacity(0.15);
      } else {
        bgColor = Colors.red.withOpacity(0.15);
      }
    }

    return Container(
      padding: EdgeInsets.all(Responsive.w(12)),
      color: bgColor,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(12),
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.w500,
          color: isDarkMode ? AppColors.darkText : AppColors.lightText,
        ),
      ),
    );
  }

  void _startTraining() {
    setState(() {
      isTraining = true;
      accuracy = 0.0;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isTraining = false;
          accuracy = 0.92 + (0.05 * (DateTime.now().millisecond % 10) / 10);
        });
      }
    });
  }
}