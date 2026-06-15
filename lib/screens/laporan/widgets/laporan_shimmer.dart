// lib/screens/laporan/widgets/laporan_shimmer.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer placeholder shown while laporan data is loading.
/// Extracted from [LaporanScreen._buildShimmerLoading].
class LaporanShimmer extends StatelessWidget {
  const LaporanShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF141E2E),
      highlightColor: const Color(0xFF1F2E46),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _block(double.infinity, 110, radius: 16),
          const SizedBox(height: 24),
          _block(140, 18, radius: 4),
          const SizedBox(height: 12),
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _block(double.infinity, 70, radius: 16),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _block(double width, double height,
      {double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
