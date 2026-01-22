import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SummarySkeleton extends StatelessWidget {
  const SummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Row(
        children: List.generate(
          3,
          (_) => Expanded(child: Card(child: const SizedBox(height: 80))),
        ),
      ),
    );
  }
}
