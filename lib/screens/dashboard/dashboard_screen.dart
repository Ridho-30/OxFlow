import 'package:flutter/material.dart';
import '../../widgets/bottom_navbar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const Text(
                'Beranda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              _buildExpenseCard(),

              const SizedBox(height: 20),

              Row(
                children: [

                  Expanded(
                    child: _buildBudgetCard(),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: _buildStatusCard(),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                'Transaksi Terbaru',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              _buildTransactionTile(
                'Indomaret',
                '- Rp 45.000',
              ),

              _buildTransactionTile(
                'Grab',
                '- Rp 28.000',
              ),

              _buildTransactionTile(
                'Kopi Kenangan',
                '- Rp 32.000',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            'Total Pengeluaran',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          SizedBox(height: 10),

          Text(
            'Rp 1.250.000',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: const Column(
        children: [

          Text(
            'Sisa Anggaran',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          SizedBox(height: 10),

          Text(
            'Rp 750.000',
            style: TextStyle(
              color: Color(0xFF00E5A8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: const Column(
        children: [

          Text(
            'Status Keuangan',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          SizedBox(height: 10),

          Text(
            'Aman',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(
    String title,
    String amount,
  ) {
    return Card(
      color: const Color(0xFF141E2E),

      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),

        trailing: Text(
          amount,
          style: const TextStyle(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}