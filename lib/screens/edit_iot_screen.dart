import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../config/responsive.dart';
import '../providers/settings_provider.dart';

class EditIoTScreen extends StatefulWidget {
  const EditIoTScreen({super.key});

  @override
  State<EditIoTScreen> createState() => _EditIoTScreenState();
}

class _EditIoTScreenState extends State<EditIoTScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Device configuration
  String deviceName = 'ESP32-AquaSense-01';
  String deviceId = 'ESP32_WQ_001';
  String wifiSSID = 'HongBang_IoT';
  String wifiPassword = '********';
  int samplingInterval = 45; // seconds
  bool autoUpload = true;
  bool ledIndicator = true;
  
  // Threshold settings
  double tdsThreshold = 500.0;
  double turbidityThreshold = 5.0;
  double phMin = 6.5;
  double phMax = 8.5;
  double tempMax = 35.0;

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
          'Cấu hình thiết bị IoT',
          style: GoogleFonts.poppins(
            color: isDarkMode ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveConfiguration,
            child: Text(
              'Lưu',
              style: GoogleFonts.poppins(
                color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(Responsive.w(16)),
            children: [
              _buildSectionTitle(isDarkMode, 'Thông tin thiết bị', Icons.devices),
              SizedBox(height: Responsive.h(12)),
              _buildDeviceInfoCard(isDarkMode),
              SizedBox(height: Responsive.h(20)),
              _buildSectionTitle(isDarkMode, 'Cấu hình WiFi', Icons.wifi),
              SizedBox(height: Responsive.h(12)),
              _buildWiFiCard(isDarkMode),
              SizedBox(height: Responsive.h(20)),
              _buildSectionTitle(isDarkMode, 'Cài đặt đo lường', Icons.settings),
              SizedBox(height: Responsive.h(12)),
              _buildMeasurementCard(isDarkMode),
              SizedBox(height: Responsive.h(20)),
              _buildSectionTitle(isDarkMode, 'Ngưỡng cảnh báo', Icons.warning_amber),
              SizedBox(height: Responsive.h(12)),
              _buildThresholdCard(isDarkMode),
              SizedBox(height: Responsive.h(80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(bool isDarkMode, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: Responsive.sp(18),
          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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

  Widget _buildDeviceInfoCard(bool isDarkMode) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          children: [
            TextFormField(
              initialValue: deviceName,
              decoration: InputDecoration(
                labelText: 'Tên thiết bị',
                prefixIcon: const Icon(Icons.label_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => deviceName = value,
            ),
            SizedBox(height: Responsive.h(16)),
            TextFormField(
              initialValue: deviceId,
              decoration: InputDecoration(
                labelText: 'Device ID',
                prefixIcon: const Icon(Icons.fingerprint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWiFiCard(bool isDarkMode) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          children: [
            TextFormField(
              initialValue: wifiSSID,
              decoration: InputDecoration(
                labelText: 'WiFi SSID',
                prefixIcon: const Icon(Icons.wifi),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => wifiSSID = value,
            ),
            SizedBox(height: Responsive.h(16)),
            TextFormField(
              initialValue: wifiPassword,
              decoration: InputDecoration(
                labelText: 'WiFi Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
              onChanged: (value) => wifiPassword = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementCard(bool isDarkMode) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Khoảng thời gian đo (giây)',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(14),
                    color: isDarkMode ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                SizedBox(
                  width: Responsive.w(80),
                  child: TextFormField(
                    initialValue: samplingInterval.toString(),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(8),
                        vertical: Responsive.h(8),
                      ),
                    ),
                    onChanged: (value) {
                      samplingInterval = int.tryParse(value) ?? 45;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(16)),
            _buildSwitchTile(
              isDarkMode,
              'Tự động tải lên',
              'Tự động gửi dữ liệu lên Supabase',
              autoUpload,
              (value) => setState(() => autoUpload = value),
            ),
            SizedBox(height: Responsive.h(8)),
            _buildSwitchTile(
              isDarkMode,
              'Đèn LED chỉ thị',
              'Hiển thị trạng thái qua đèn LED',
              ledIndicator,
              (value) => setState(() => ledIndicator = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdCard(bool isDarkMode) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          children: [
            _buildSliderTile(
              isDarkMode,
              'TDS tối đa',
              tdsThreshold,
              'ppm',
              0,
              1000,
              (value) => setState(() => tdsThreshold = value),
            ),
            SizedBox(height: Responsive.h(16)),
            _buildSliderTile(
              isDarkMode,
              'Độ đục tối đa',
              turbidityThreshold,
              'NTU',
              0,
              10,
              (value) => setState(() => turbidityThreshold = value),
            ),
            SizedBox(height: Responsive.h(16)),
            _buildSliderTile(
              isDarkMode,
              'pH tối thiểu',
              phMin,
              '',
              0,
              14,
              (value) => setState(() => phMin = value),
            ),
            SizedBox(height: Responsive.h(16)),
            _buildSliderTile(
              isDarkMode,
              'pH tối đa',
              phMax,
              '',
              0,
              14,
              (value) => setState(() => phMax = value),
            ),
            SizedBox(height: Responsive.h(16)),
            _buildSliderTile(
              isDarkMode,
              'Nhiệt độ tối đa',
              tempMax,
              '°C',
              0,
              50,
              (value) => setState(() => tempMax = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    bool isDarkMode,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(14),
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(11),
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
        ),
      ],
    );
  }

  Widget _buildSliderTile(
    bool isDarkMode,
    String title,
    double value,
    String unit,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(14),
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)} $unit',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(14),
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * 10).toInt(),
          onChanged: onChanged,
          activeColor: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
        ),
      ],
    );
  }

  void _saveConfiguration() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cấu hình đã được lưu thành công!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // In a real app, you would save to database or send to ESP32
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }
}