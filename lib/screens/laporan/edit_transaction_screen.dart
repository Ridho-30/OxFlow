import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/transaction_form_fields.dart';
import '../../models/transaction/transaction_model.dart';
import '../navigation/main_navigation_screen.dart';

class EditTransactionScreen extends ConsumerWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Transaksi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: TransactionFormFields(
            existingTransaction: transaction,
            onSuccess: () {
              // Usually when we edit a transaction from Laporan, 
              // we can just pop back to Laporan.
              // But popping once might go back to the transaction detail sheet 
              // which would be stale or closed.
              // Actually, closing the sheet and then navigating is better.
              Navigator.pop(context); // This pops EditTransactionScreen
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
