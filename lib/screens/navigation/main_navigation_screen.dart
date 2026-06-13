import 'package:flutter/material.dart';

import '../dashboard/dashboard_screen.dart';
import '../scanner/scanner_screen.dart';
import '../budget/budget_screen.dart';
import '../laporan/laporan_screen.dart';
import '../profile/profile_screen.dart';

import '../../widgets/bottom_navbar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool _isPopupOpen = false;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const LaporanScreen(), // Used as the Laporan screen
    const BudgetScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _togglePopup() {
    setState(() {
      _isPopupOpen = !_isPopupOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectedIndex],
          if (_isPopupOpen) _buildPopupOverlay(),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        isPopupOpen: _isPopupOpen,
        onCenterTap: _togglePopup,
      ),
    );
  }

  Widget _buildPopupOverlay() {
    return Stack(
      children: [
        // Dimmed background barrier
        GestureDetector(
          onTap: () {
            setState(() {
              _isPopupOpen = false;
            });
          },
          child: Container(color: Colors.black.withOpacity(0.7)),
        ),
        // Popup container positioned above the bottom navbar
        Positioned(
          left: 20,
          right: 20,
          bottom: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF141E2E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF1F2E46), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tambah transaksi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPopupButton(
                      icon: Icons.camera_alt_outlined,
                      iconColor: const Color(0xFF00E5A8),
                      bgColor: const Color(0xFF0C2B29),
                      label: 'Scan struk',
                      onTap: () {
                        setState(() {
                          _isPopupOpen = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScannerScreen(),
                          ),
                        );
                      },
                    ),
                    _buildPopupButton(
                      icon: Icons.edit_outlined,
                      iconColor: const Color(0xFF3897F5),
                      bgColor: const Color(0xFF122036),
                      label: 'Input manual',
                      onTap: () {
                        setState(() {
                          _isPopupOpen = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Input manual diklik'),
                            backgroundColor: Color(0xFF141E2E),
                          ),
                        );
                      },
                    ),
                    _buildPopupButton(
                      icon: Icons.image_outlined,
                      iconColor: const Color(0xFFA55EEA),
                      bgColor: const Color(0xFF251A3B),
                      label: 'Dari galeri',
                      onTap: () {
                        setState(() {
                          _isPopupOpen = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pilih dari galeri diklik'),
                            backgroundColor: Color(0xFF141E2E),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopupButton({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
