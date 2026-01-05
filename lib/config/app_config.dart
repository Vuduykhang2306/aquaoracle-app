class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = "https://YOUR_PROJECT_REF.supabase.co";
  static const String supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY";
  
  // Gemini AI Configuration
  static const String geminiApiKey = "YOUR_GEMINI_API_KEY"; // <-- PASTE YOUR KEY HERE
  static const String geminiApiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent";
  
  // App Settings
  static const int autoRefreshSeconds = 45;
  static const int historyLimit = 30;
  static const int displayHistoryLimit = 15;
}