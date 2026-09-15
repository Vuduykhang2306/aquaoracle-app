// Cấu hình của app. Không để khoá trong file này nữa, truyền lúc build
// bằng --dart-define. Cách chạy ghi trong README.
class AppConfig {
  // Supabase
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Gemini
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  static const String geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  // Mấy con số cho phần hiển thị
  static const int autoRefreshSeconds = 45;
  static const int historyLimit = 30;
  static const int displayHistoryLimit = 15;

  // Gọi lúc khởi động cho chắc. Thiếu khoá thì báo ngay, đỡ phải ngồi mò
  // xem sao API trả về 401.
  static void assertConfigured() {
    assert(
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty,
      'Thiếu SUPABASE_URL / SUPABASE_ANON_KEY. Chạy bằng --dart-define, xem README.',
    );
  }
}
