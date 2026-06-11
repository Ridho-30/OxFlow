import 'package:flutter/material.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        title: const Text(
          'Anggaran',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            _buildBudgetCard(),

            const SizedBox(height: 25),

            const Text(
              'Status Anggaran',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color(0xFF141E2E),
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Text(
                'Pengeluaran masih terkendali',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const Text(
            'Anggaran Bulanan',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Rp 2.500.000',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: const [

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    'Anggaran',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Rp 1.250.000',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,

                children: [

                  Text(
                    'Sisa Anggaran',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Rp 1.250.000',
                    style: TextStyle(
                      color: Color(0xFF00E5A8),
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 25),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),

            child: const LinearProgressIndicator(
              value: 0.5,
              minHeight: 10,
              backgroundColor:
                  Color(0xFF0B1220),
              valueColor:
                  AlwaysStoppedAnimation(
                Color(0xFF00E5A8),
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '50%',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}