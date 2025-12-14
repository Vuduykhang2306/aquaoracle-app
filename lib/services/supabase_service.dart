import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/water_quality.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;

  SupabaseClient get client => _client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  Future<bool> authenticateDevice(String espId, String password) async {
    try {
      final response = await _client
          .from('esp_devices')
          .select()
          .eq('esp_id', espId)
          .eq('esp_password', password)
          .timeout(const Duration(seconds: 10));

      return response.isNotEmpty;
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  Future<WaterQuality?> getLatestWaterQuality() async {
    try {
      final response = await _client
          .from('water_quality')
          .select()
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;
      return WaterQuality.fromJson(response.first);
    } catch (e) {
      throw Exception('Failed to fetch latest data: $e');
    }
  }

  Future<List<WaterQuality>> getWaterQualityHistory({int limit = 30}) async {
    try {
      final response = await _client
          .from('water_quality')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((json) => WaterQuality.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch history: $e');
    }
  }
}