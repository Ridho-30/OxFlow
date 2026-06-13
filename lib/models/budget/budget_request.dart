// lib/models/budget/budget_request.dart

class BudgetRequest {
  final double income;
  final double threshold;

  BudgetRequest({
    required this.income,
    required this.threshold,
  });

  Map<String, dynamic> toJson() => {
        'income': income,
        'threshold': threshold,
      };
}
