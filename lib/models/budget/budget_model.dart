// lib/models/budget/budget_model.dart

import 'package:flutter/material.dart';

class BudgetModel {
  final String id;
  final String userId;
  final double income;
  final double threshold;
  final double totalSpentThisMonth;
  final double remaining;
  final int percentageUsed;
  final String status; // 'normal', 'warning', 'danger'
  final String description;
  final DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.income,
    required this.threshold,
    required this.totalSpentThisMonth,
    required this.remaining,
    required this.percentageUsed,
    required this.status,
    required this.description,
    required this.updatedAt,
  });

  bool get isWarning => status == 'warning';
  bool get isExceeded => status == 'danger';
  bool get isNormal => status == 'normal';

  Color get statusColor {
    if (isExceeded) return const Color(0xFFEB5757);
    if (isWarning) return const Color(0xFFF2C94C);
    return const Color(0xFF00E5A8);
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      // API returns id as int (e.g. 1) — always coerce to String
      id: json['id']?.toString() ?? json['budget_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      income: _toDouble(json['income']),
      threshold: _toDouble(json['threshold']),
      totalSpentThisMonth: _toDouble(json['total_spent_this_month']),
      remaining: _toDouble(json['remaining']),
      percentageUsed: _toInt(json['percentage_used']),
      status: json['status']?.toString() ?? 'normal',
      description: json['description']?.toString() ?? '',
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  // ── Safe type helpers ────────────────────────────────────────────────────

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static DateTime _toDateTime(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'income': income,
        'threshold': threshold,
      };
}

