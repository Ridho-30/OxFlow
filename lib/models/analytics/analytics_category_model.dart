// lib/models/analytics/analytics_category_model.dart

class AnalyticsCategoryModel {
  final int categoryId;
  final String categoryName;
  final double total;
  final double percentage;

  AnalyticsCategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.total,
    required this.percentage,
  });

  factory AnalyticsCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['category_id'] ?? json['categoryId'] ?? json['kategori_id'] ?? json['id'];
    final int parsedId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;

    String name = 'Lainnya';
    for (final key in ['category_name', 'name_category', 'nameCategory', 'kategori_nama', 'name', 'label']) {
      final val = json[key]?.toString().trim() ?? '';
      if (val.isNotEmpty) {
        name = val;
        break;
      }
    }

    final rawTotal = json['total'] ?? json['total_spent'] ?? json['totalSpent'] ?? json['amount'] ?? json['spent'];
    final double parsedTotal = (rawTotal as num?)?.toDouble() ?? 0.0;

    final rawPct = json['percentage'] ?? json['persentase'] ?? json['pct'];
    final double parsedPct = (rawPct as num?)?.toDouble() ?? 0.0;

    return AnalyticsCategoryModel(
      categoryId: parsedId,
      categoryName: name,
      total: parsedTotal,
      percentage: parsedPct,
    );
  }

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'category_name': categoryName,
        'total': total,
        'percentage': percentage,
      };
}
