// lib/models/analytics/dashboard_model.dart

class DashboardSummaryModel {
  final double income;
  final double threshold;
  final double totalSpent;
  final double remaining;
  final double percentageSpent;
  final String status;

  DashboardSummaryModel({
    required this.income,
    required this.threshold,
    required this.totalSpent,
    required this.remaining,
    required this.percentageSpent,
    required this.status,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      threshold: (json['threshold'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
      percentageSpent: (json['percentage_spent'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'normal',
    );
  }
}

class DashboardMonthInfoModel {
  final int month;
  final String monthName;
  final int year;
  final String monthLabel;
  final int totalTransactions;

  DashboardMonthInfoModel({
    required this.month,
    required this.monthName,
    required this.year,
    required this.monthLabel,
    required this.totalTransactions,
  });

  factory DashboardMonthInfoModel.fromJson(Map<String, dynamic> json) {
    return DashboardMonthInfoModel(
      month: json['month'] as int? ?? 1,
      monthName: json['month_name']?.toString() ?? '',
      year: json['year'] as int? ?? DateTime.now().year,
      monthLabel: json['month_label']?.toString() ?? '',
      totalTransactions: json['total_transactions'] as int? ?? 0,
    );
  }
}

class DashboardWeeklyChartItemModel {
  final String date;
  final String day;
  final double total;

  DashboardWeeklyChartItemModel({
    required this.date,
    required this.day,
    required this.total,
  });

  factory DashboardWeeklyChartItemModel.fromJson(Map<String, dynamic> json) {
    return DashboardWeeklyChartItemModel(
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardTopCategoryModel {
  final int categoryId;
  final String categoryName;
  final double totalSpent;
  final double percentage;

  DashboardTopCategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.totalSpent,
    required this.percentage,
  });

  factory DashboardTopCategoryModel.fromJson(Map<String, dynamic> json) {
    return DashboardTopCategoryModel(
      categoryId: json['kategori_id'] as int? ?? 0,
      categoryName: json['kategori_nama']?.toString() ?? 'Lainnya',
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardModel {
  final DashboardSummaryModel summary;
  final DashboardMonthInfoModel thisMonthInfo;
  final List<DashboardWeeklyChartItemModel> weeklyChart;
  final List<DashboardTopCategoryModel> topCategories;

  DashboardModel({
    required this.summary,
    required this.thisMonthInfo,
    required this.weeklyChart,
    required this.topCategories,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final summaryData = json['summary'] != null
        ? DashboardSummaryModel.fromJson(json['summary'] as Map<String, dynamic>)
        : DashboardSummaryModel(
            income: 0.0,
            threshold: 0.0,
            totalSpent: 0.0,
            remaining: 0.0,
            percentageSpent: 0.0,
            status: 'normal',
          );

    final thisMonthInfoData = json['this_month_info'] != null
        ? DashboardMonthInfoModel.fromJson(
            json['this_month_info'] as Map<String, dynamic>)
        : DashboardMonthInfoModel(
            month: 1,
            monthName: '',
            year: DateTime.now().year,
            monthLabel: '',
            totalTransactions: 0,
          );

    final weeklyChartList = <DashboardWeeklyChartItemModel>[];
    if (json['weekly_chart'] != null) {
      final list = json['weekly_chart'] as List;
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          weeklyChartList.add(DashboardWeeklyChartItemModel.fromJson(item));
        }
      }
    }

    final topCategoriesList = <DashboardTopCategoryModel>[];
    if (json['top_categories'] != null) {
      final list = json['top_categories'] as List;
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          topCategoriesList.add(DashboardTopCategoryModel.fromJson(item));
        }
      }
    }

    return DashboardModel(
      summary: summaryData,
      thisMonthInfo: thisMonthInfoData,
      weeklyChart: weeklyChartList,
      topCategories: topCategoriesList,
    );
  }
}
