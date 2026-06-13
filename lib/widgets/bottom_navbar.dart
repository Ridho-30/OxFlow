import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isPopupOpen;
  final VoidCallback onCenterTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isPopupOpen,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF141E2E),
        border: Border(
          top: BorderSide(color: Color(0xFF1F2E46), width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              isActive: currentIndex == 0 && !isPopupOpen,
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.description_outlined,
              activeIcon: Icons.description,
              label: 'Laporan',
              isActive: currentIndex == 1 && !isPopupOpen,
            ),
            _buildCenterItem(),
            _buildNavItem(
              index: 2,
              icon: Icons.pie_chart_outline,
              activeIcon: Icons.pie_chart,
              label: 'Anggaran',
              isActive: currentIndex == 2 && !isPopupOpen,
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profil',
              isActive: currentIndex == 3 && !isPopupOpen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
  }) {
    final color = isActive ? const Color(0xFF00E5A8) : Colors.grey;
    return GestureDetector(
      onTap: isPopupOpen ? null : () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterItem() {
    return GestureDetector(
      onTap: onCenterTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPopupOpen
                    ? const Color(0xFF2E3B52) // Dark background when popup is open
                    : const Color(0xFF00E5A8), // Green background when popup is closed
              ),
              child: Icon(
                isPopupOpen ? Icons.close : Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isPopupOpen ? 'Tutup' : 'Catat',
              style: TextStyle(
                color: isPopupOpen ? Colors.grey : const Color(0xFF00E5A8),
                fontSize: 12,
                fontWeight: isPopupOpen ? FontWeight.normal : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}