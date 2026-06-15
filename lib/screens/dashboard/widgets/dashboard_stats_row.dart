// lib/screens/dashboard/widgets/dashboard_stats_row.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/analytics/dashboard_model.dart';

/// Two-column info row showing "Sisa" and budget "Status".
/// Extracted from [DashboardScreen._buildStatsRow] and [_buildInfoCard].
class DashboardStatsRow extends StatelessWidget {
  final DashboardSummaryModel? summary;

  const DashboardStatsRow({super.key, this.summary});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final double remaining = summary?.remaining ?? 0.0;
    final String status = summary?.status ?? 'normal';

    final Color statusColor = status == 'danger'
        ? const Color(0xFFEB5757)
        : status == 'warning'
            ? const Color(0xFFF2C94C)
            : const Color(0xFF00E5A8);

    final String statusText = status == 'danger'
        ? 'Bahaya'
        : status == 'warning'
            ? 'Peringatan'
            : 'Aman';

    return Row(
      children: [
        Expanded(
          child: _DashboardInfoCard(
            title: 'Sisa',
            value: fmt.format(remaining),
            valueColor: remaining < 0
                ? const Color(0xFFEB5757)
                : const Color(0xFF00E5A8),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _DashboardInfoCard(
            title: 'Status',
            value: statusText,
            valueColor: statusColor,
          ),
        ),
      ],
    );
  }
}

// ── Private info card ─────────────────────────────────────────────────────────

/// Small metric card used inside [DashboardStatsRow].
/// Private — not intended for use outside this file.
class _DashboardInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _DashboardInfoCard({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2E46)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Color(0xFF8A99AD), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
