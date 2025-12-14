class WaterQuality {
  final double tds;
  final double turbidity;
  final double ph;
  final double temperature;
  final DateTime createdAt;

  WaterQuality({
    required this.tds,
    required this.turbidity,
    required this.ph,
    required this.temperature,
    required this.createdAt,
  });

  factory WaterQuality.fromJson(Map<String, dynamic> json) {
    return WaterQuality(
      tds: (json['tds'] ?? 0).toDouble(),
      turbidity: (json['turbidity'] ?? 0).toDouble(),
      ph: (json['ph'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tds': tds,
      'turbidity': turbidity,
      'ph': ph,
      'temperature': temperature,
      'created_at': createdAt.toIso8601String(),
    };
  }
}