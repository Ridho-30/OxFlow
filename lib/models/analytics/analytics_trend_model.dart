// lib/models/analytics/analytics_trend_model.dart

class AnalyticsTrendModel {
  final String period;
  final double total;

  AnalyticsTrendModel({
    required this.period,
    required this.total,
  });

  factory AnalyticsTrendModel.fromJson(Map<String, dynamic> json) {
    final rawTotal = json['total'] ?? json['total_spent'] ?? json['totalSpent'] ?? json['amount'] ?? json['spent'];
    return AnalyticsTrendModel(
      period: json['period']?.toString() ?? json['minggu']?.toString() ?? '',
      total: (rawTotal as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'period': period,
        'total': total,
      };
}
