// lib/screens/laporan/utils/laporan_utils.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ── Shared formatters (created once, reused everywhere) ───────────────────────

final _kCurrencyFmt = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

final _kFullDateFmt = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
final _kDayMonthFmt = DateFormat('dd MMM', 'id_ID');
final _kFullFmt = DateFormat('dd MMMM yyyy', 'id_ID');

// ── Month names ───────────────────────────────────────────────────────────────

const kMonthNames = [
  'Januari', 'Februari', 'Maret', 'April',
  'Mei', 'Juni', 'Juli', 'Agustus',
  'September', 'Oktober', 'November', 'Desember',
];

// ── Formatting helpers ────────────────────────────────────────────────────────

String formatCurrency(double amount) => _kCurrencyFmt.format(amount);

String formatIndonesianDate(DateTime date) => _kFullDateFmt.format(date);

String formatWeekRange(DateTime date) {
  final monday = date.subtract(Duration(days: date.weekday - 1));
  final sunday = date.add(Duration(days: 7 - date.weekday));

  if (monday.year == sunday.year) {
    if (monday.month == sunday.month) {
      return '${monday.day} - ${_kFullFmt.format(sunday)}';
    }
    return '${_kDayMonthFmt.format(monday)} - ${_kFullFmt.format(sunday)}';
  }
  return '${_kFullFmt.format(monday)} - ${_kFullFmt.format(sunday)}';
}

// ── Category logic ────────────────────────────────────────────────────────────

const _kIncomeCategories = {'gaji', 'pemasukan', 'income'};

bool isIncomeCategory(String categoryName) =>
    _kIncomeCategories.contains(categoryName.toLowerCase());

IconData getCategoryIcon(String categoryName) {
  final name = categoryName.toLowerCase();
  if (name.contains('makan')) {
    return Icons.fastfood;
  }
  if (name.contains('transport')) {
    return Icons.directions_car;
  }
  if (name.contains('belanja')) {
    return Icons.shopping_bag;
  }
  if (name.contains('gaji') ||
      name.contains('pemasukan') ||
      name.contains('income')) {
    return Icons.monetization_on;
  }
  if (name.contains('hiburan') ||
      name.contains('entertainment') ||
      name.contains('rekreasi') ||
      name.contains('nonton')) {
    return Icons.movie;
  }
  if (name.contains('kesehatan') ||
      name.contains('obat') ||
      name.contains('dokter')) {
    return Icons.medical_services;
  }
  return Icons.category;
}

Color getCategoryColor(int categoryId, String categoryName) {
  final name = categoryName.toLowerCase();
  if (name.contains('makan')) {
    return const Color(0xFF00E5A8);
  }
  if (name.contains('transport')) {
    return const Color(0xFF2F80ED);
  }
  if (name.contains('belanja')) {
    return const Color(0xFFF2C94C);
  }
  if (name.contains('gaji') ||
      name.contains('pemasukan') ||
      name.contains('income')) {
    return const Color(0xFF27AE60);
  }
  if (name.contains('hiburan') ||
      name.contains('entertainment') ||
      name.contains('rekreasi')) {
    return const Color(0xFFBB6BD9);
  }
  const fallback = [
    Color(0xFFEB5757),
    Color(0xFFF2994A),
    Color(0xFF56CCF2),
    Color(0xFF9B51E0),
    Color(0xFF2196F3),
  ];
  return fallback[categoryId % fallback.length];
}

