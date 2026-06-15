// lib/screens/laporan/widgets/laporan_common_widgets.dart
//
// Shared small widgets used across all three laporan tabs.

import 'package:flutter/material.dart';

// ── LaporanEmptyState ─────────────────────────────────────────────────────────

/// Generic empty state widget for laporan tabs.
class LaporanEmptyState extends StatelessWidget {
  final String message;

  const LaporanEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8A99AD),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── LaporanErrorState ─────────────────────────────────────────────────────────

/// Error state with a retry button for laporan tabs.
class LaporanErrorState extends StatelessWidget {
  final String errorMsg;
  final VoidCallback onRetry;

  const LaporanErrorState({
    super.key,
    required this.errorMsg,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final friendlyMessage =
        errorMsg.contains('401') || errorMsg.contains('Unauthorized')
            ? 'Sesi Anda telah berakhir. Silakan login kembali.'
            : 'Gagal memuat data dari API: $errorMsg';

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 56, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              friendlyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF8A99AD), fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5A8),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── LaporanSummaryRow ─────────────────────────────────────────────────────────

/// A single label ↔ colored value row inside a summary card.
/// Used in both Mingguan and Bulanan summary cards.
class LaporanSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const LaporanSummaryRow({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF8A99AD), fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ── LaporanLegendItem ─────────────────────────────────────────────────────────

/// Colored dot + label for pie chart legends.
class LaporanLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LaporanLegendItem({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

// ── LaporanCategoryProgressItem ───────────────────────────────────────────────

/// Category progress bar row used in Bulanan tab.
class LaporanCategoryProgressItem extends StatelessWidget {
  final String label;
  final String amount;
  final double progress;
  final Color color;

  const LaporanCategoryProgressItem({
    super.key,
    required this.label,
    required this.amount,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress =
        progress.isNaN || progress.isInfinite ? 0.0 : progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                )),
            Text(amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: safeProgress,
            minHeight: 6,
            backgroundColor: const Color(0xFF0B1220),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
