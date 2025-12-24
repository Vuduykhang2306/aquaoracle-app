import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import '../models/water_quality.dart';

class AIAnalysisService {
  static final AIAnalysisService _instance = AIAnalysisService._internal();
  factory AIAnalysisService() => _instance;
  AIAnalysisService._internal();

  Future<String> analyzeWaterQuality(
    WaterQuality current,
    List<WaterQuality> history,
  ) async {
    try {
      final historyText = history.take(10).map((item) {
        return "Ngày ${item.createdAt.day}/${item.createdAt.month}: TDS=${item.tds}ppm, Độ đục=${item.turbidity}NTU, pH=${item.ph}, Temp=${item.temperature}°C";
      }).join("; ");

      final prompt = """
Phân tích chất lượng nước với vai trò chuyên gia về môi trường thủy sản :

HIỆN TẠI: TDS=${current.tds.toStringAsFixed(1)}ppm, Độ đục=${current.turbidity.toStringAsFixed(2)}NTU, pH=${current.ph.toStringAsFixed(1)}, Temp=${current.temperature.toStringAsFixed(1)}°C
LỊCH SỬ: $historyText

Hãy:
1. Đánh giá tình trạng hiện tại (tốt/trung bình/kém) dựa trên TẤT CẢ các chỉ số (TDS, Độ đục, pH, Nhiệt độ).
2. Xác định nước có an toàn để nuôi tôm thẻ hay ko ?.
3. Phân tích xu hướng từ lịch sử.
4. Dự đoán 5-7 ngày tới.
5. Khuyến nghị hành động cụ thể.

Trả lời ngắn gọn 4-5 câu bằng tiếng Việt với emoji phù hợp.
""";

      final response = await http.post(
        Uri.parse("${AppConfig.geminiApiUrl}?key=${AppConfig.geminiApiKey}"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 300,
          }
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'].toString().trim();
      } else {
        throw Exception('Gemini API Error: ${response.statusCode}');
      }
    } catch (e) {
      return _generateSmartAnalysis(current, history);
    }
  }

  String _generateSmartAnalysis(WaterQuality current, List<WaterQuality> history) {
    String trendAnalysis = "";
    String recommendation = "";
    
    if (history.length >= 5) {
      final recent5 = history.take(5).toList();
      final avgTdsRecent = recent5.map((e) => e.tds).reduce((a, b) => a + b) / 5;
      final avgTurbidityRecent = recent5.map((e) => e.turbidity).reduce((a, b) => a + b) / 5;
      
      final older5 = history.skip(5).take(5).toList();
      if (older5.length == 5) {
        final avgTdsOlder = older5.map((e) => e.tds).reduce((a, b) => a + b) / 5;
        final avgTurbidityOlder = older5.map((e) => e.turbidity).reduce((a, b) => a + b) / 5;
        
        final tdsTrend = avgTdsRecent - avgTdsOlder;
        final turbidityTrend = avgTurbidityRecent - avgTurbidityOlder;
        
        if (tdsTrend > 20 || turbidityTrend > 1) {
          trendAnalysis = "Xu hướng: Chất lượng nước đang giảm trong 10 ngày qua";
        } else if (tdsTrend < -20 || turbidityTrend < -1) {
          trendAnalysis = "Xu hướng: Chất lượng nước đang cải thiện";
        } else {
          trendAnalysis = "Xu hướng: Chất lượng nước tương đối ổn định";
        }
      }
    }

    String currentStatus = "";
    bool isPhBad = current.ph < 6.5 || current.ph > 8.5;

    if (current.tds < 300 && current.turbidity < 2 && !isPhBad) {
      currentStatus = "🌟 Chất lượng nước hiện tại: Tuyệt vời";
      recommendation = "Duy trì chế độ bảo trì định kỳ";
    } else if (current.tds < 500 && current.turbidity < 5 && !isPhBad) {
      currentStatus = "⚠️ Chất lượng nước hiện tại: Trung bình";
      recommendation = "Kiểm tra và vệ sinh bộ lọc trong 2-3 ngày tới";
    } else {
      currentStatus = "🚨 Chất lượng nước hiện tại: Kém";
      if (isPhBad) {
        recommendation = "pH không ổn định (${current.ph}). Cần xử lý cân bằng pH ngay.";
      } else {
        recommendation = "Cần thay thế bộ lọc ngay lập tức";
      }
    }

    String prediction = "";
    if (trendAnalysis.contains("giảm")) {
      prediction = "Dự đoán: Chất lượng có thể tiếp tục xấu đi trong 5-7 ngày tới";
    } else if (trendAnalysis.contains("cải thiện")) {
      prediction = "Dự đoán: Chất lượng sẽ tiếp tục ổn định hoặc tốt hơn";
    } else {
      prediction = "Dự đoán: Chất lượng sẽ duy trì ở mức hiện tại";
    }

    String drinkability = getDrinkabilityStatus(current);

    return "$currentStatus. $trendAnalysis. $prediction. 💡 Khuyến nghị: $recommendation. Tình trạng uống: $drinkability.";
  }

  String getDrinkabilityStatus(WaterQuality data) {
    if (data.tds <= 500 && data.turbidity <= 5 && data.ph >= 6.5 && data.ph <= 8.5) {
      return "An toàn để uống";
    } else {
      return "Không an toàn để uống";
    }
  }
}