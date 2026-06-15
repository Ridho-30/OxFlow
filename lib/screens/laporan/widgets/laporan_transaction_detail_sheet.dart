// lib/screens/laporan/widgets/laporan_transaction_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/laporan_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../edit_transaction_screen.dart';
import '../utils/laporan_utils.dart';

/// Shows a draggable modal bottom sheet with full transaction detail.
/// Extracted from [LaporanScreen._showTransactionDetails] (220+ inline lines).
///
/// Usage:
/// ```dart
/// showTransactionDetailSheet(context, ref, tx.id);
/// ```
Future<void> showTransactionDetailSheet(
  BuildContext context,
  WidgetRef ref,
  String transactionId,
) async {
  final notifier = ref.read(laporanProvider.notifier);

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF141E2E),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) =>
          _TransactionDetailContent(scrollController: scrollController),
    ),
  ).then((_) => notifier.clearActiveDetail());

  await notifier.fetchTransactionDetail(transactionId);
}

// ── Detail content widget ─────────────────────────────────────────────────────

class _TransactionDetailContent extends ConsumerWidget {
  final ScrollController scrollController;

  const _TransactionDetailContent({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(laporanProvider);
    final tx = state.activeTransactionDetail;
    final bool isLoading = state.isDetailLoading;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00E5A8)),
      );
    }

    if (tx == null) {
      return const Center(
        child: Text(
          'Gagal memuat detail transaksi',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final bool isIncome = isIncomeCategory(tx.category?.nameCategory ?? '');
    final amountStr = isIncome
        ? '+${formatCurrency(tx.total)}'
        : '-${formatCurrency(tx.total)}';

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Detail Transaksi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF00E5A8)),
                onPressed: () {
                  Navigator.pop(context); // close sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditTransactionScreen(transaction: tx),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () async {
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      backgroundColor: const Color(0xFF141E2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        'Hapus Transaksi?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text(
                        'Transaksi ini akan dihapus. Tindakan ini tidak dapat dibatalkan.',
                        style: TextStyle(color: Color(0xFF8A99AD)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx, false),
                          child: const Text(
                            'Batal',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(dialogCtx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    try {
                      await ref
                          .read(laporanProvider.notifier)
                          .deleteTransaction(tx.id);
                      if (context.mounted) {
                        Navigator.pop(context); // close sheet
                        ref.invalidate(dashboardProvider);
                        ref.invalidate(laporanProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Transaksi berhasil dihapus',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Color(0xFF0C2B29),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Gagal menghapus: $e',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: Color(0xFF1F2E46)),
          const SizedBox(height: 16),

          // Key detail rows
          _DetailRow('Nama Toko', tx.title),
          _DetailRow('Kategori', tx.category?.nameCategory ?? 'Lainnya'),
          _DetailRow(
            'Tanggal',
            DateFormat('dd MMMM yyyy', 'id_ID').format(tx.date),
          ),
          _DetailRow(
            'Total Nominal',
            amountStr,
            valueColor: isIncome ? const Color(0xFF00E5A8) : Colors.redAccent,
          ),

          // Receipt photo
          if (tx.fotoStruk != null && tx.fotoStruk!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Foto Struk',
              style: TextStyle(color: Color(0xFF8A99AD), fontSize: 14),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                tx.fotoStruk!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: const Color(0xFF0B1220),
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.grey, size: 36),
                      SizedBox(height: 8),
                      Text(
                        'Gambar gagal dimuat',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Item list
          if (tx.details.isNotEmpty) ...[
            const Text(
              'DAFTAR ITEM',
              style: TextStyle(
                color: Color(0xFF8A99AD),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tx.details.length,
              itemBuilder: (_, index) =>
                  _DetailItemCard(detail: tx.details[index]),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── _DetailRow ────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ── _DetailItemCard ───────────────────────────────────────────────────────────

class _DetailItemCard extends StatelessWidget {
  final dynamic detail; // TransactionDetailModel

  const _DetailItemCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1F2E46)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.nameItems as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${detail.quantity} x ${formatCurrency(detail.price as double)}',
                  style: const TextStyle(
                    color: Color(0xFF8A99AD),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(detail.subtotal as double),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
