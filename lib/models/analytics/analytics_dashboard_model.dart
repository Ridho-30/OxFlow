// lib/models/analytics/analytics_dashboard_model.dart

class AnalyticsDashboardModel {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final double avgDailyExpense;
  final int transactionCount;

  AnalyticsDashboardModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.avgDailyExpense,
    required this.transactionCount,
  });

  factory AnalyticsDashboardModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> source = json['summary'] != null 
        ? json['summary'] as Map<String, dynamic> 
        : json;

    final rawIncome = source['total_income'] ?? source['income'] ?? source['pemasukan'];
    final rawExpense = source['total_expense'] ?? source['total_spent'] ?? source['expense'] ?? source['pengeluaran'];
    final rawBalance = source['balance'] ?? source['remaining'] ?? source['saldo'] ?? (rawIncome != null && rawExpense != null ? (rawIncome as num).toDouble() - (rawExpense as num).toDouble() : null);
    final rawAvg = json['avg_daily_expense'] ?? json['avg_daily'] ?? json['average_daily_expense'] ?? source['avg_daily_expense'] ?? source['avg_daily'] ?? source['average_daily_expense'];
    final rawCount = json['transaction_count'] ?? json['count'] ?? json['total_transactions'] ?? 
                     (json['this_month_info'] != null ? (json['this_month_info'] as Map)['total_transactions'] : null);

    final double parsedExpense = (rawExpense as num?)?.toDouble() ?? 0.0;
    double parsedAvg = (rawAvg as num?)?.toDouble() ?? 0.0;

    // Fallback: compute avg daily from total expense if API doesn't return it
    if (parsedAvg == 0.0 && parsedExpense > 0) {
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      parsedAvg = parsedExpense / daysInMonth;
    }

    return AnalyticsDashboardModel(
      totalIncome: (rawIncome as num?)?.toDouble() ?? 0.0,
      totalExpense: parsedExpense,
      balance: (rawBalance as num?)?.toDouble() ?? 0.0,
      avgDailyExpense: parsedAvg,
      transactionCount: rawCount is int ? rawCount : int.tryParse(rawCount?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_income': totalIncome,
        'total_expense': totalExpense,
        'balance': balance,
        'avg_daily_expense': avgDailyExpense,
        'transaction_count': transactionCount,
      };
}
