/// Cấu hình runtime của ứng dụng.
///
/// Không hardcode khoá vào đây. Mọi giá trị nhạy cảm đọc từ biến biên dịch,
/// truyền lúc build bằng --dart-define (xem README).
class AppConfig {
  // --- Supabase ---
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // --- Gemini ---
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  static const String geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  // --- Tham số hiển thị ---
  static const int autoRefreshSeconds = 45;
  static const int historyLimit = 30;
  static const int displayHistoryLimit = 15;

  /// Dừng sớm với thông báo rõ ràng thay vì để lỗi 401 khó hiểu lúc chạy.
  static void assertConfigured() {
    assert(
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty,
      'Thiếu SUPABASE_URL / SUPABASE_ANON_KEY. Chạy bằng --dart-define, xem README.',
    );
  }
}
