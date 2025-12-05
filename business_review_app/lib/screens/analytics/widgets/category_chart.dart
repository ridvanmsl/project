/// Category performance chart widget
import 'package:flutter/material.dart';
import '../../../models/analytics.dart';

class CategoryChart extends StatelessWidget {
  final List<CategoryBreakdown> breakdown;

  const CategoryChart({super.key, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: breakdown.take(5).map((cat) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cat.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '${cat.total} mentions',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;
                      final positiveWidth = maxWidth * (cat.positivePct / 100);
                      final negativeWidth = maxWidth * (cat.negativePct / 100);
                      final neutralWidth = maxWidth * (cat.neutralPct / 100);
                      
                      return Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Row(
                            children: [
                              // Positive bar (green)
                              if (cat.positivePct > 0)
                                Container(
                                  width: positiveWidth,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade400,
                                        Colors.green.shade600,
                                      ],
                                    ),
                                  ),
                                ),
                              // Negative bar (red)
                              if (cat.negativePct > 0)
                                Container(
                                  width: negativeWidth,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.red.shade400,
                                        Colors.red.shade600,
                                      ],
                                    ),
                                  ),
                                ),
                              // Neutral bar (gray)
                              if (cat.neutralPct > 0)
                                Container(
                                  width: neutralWidth,
                                  height: 8,
                                  color: Colors.grey.shade300,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${cat.positivePct.toStringAsFixed(1)}% Positive',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${cat.negativePct.toStringAsFixed(1)}% Negative',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

