import 'package:flutter/material.dart';

class AnalyticsSkeleton extends StatelessWidget {
  const AnalyticsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;

    Widget skeletonBox({double height = 200}) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title skeleton
        Container(
          height: 20,
          width: 120,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 16),

        // Line chart skeleton
        skeletonBox(height: 220),
        const SizedBox(height: 24),

        // Pie chart skeleton
        skeletonBox(height: 240),
        const SizedBox(height: 24),

        // Bar chart skeleton
        skeletonBox(height: 200),
      ],
    );
  }
}
