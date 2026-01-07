import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localization.dart';
import '../../../providers/language_provider.dart';

/// Pie chart showing sentiment distribution
class SentimentChart extends StatelessWidget {
  final Map<String, int> sentimentStats;

  const SentimentChart({
    super.key,
    required this.sentimentStats,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<LanguageProvider>().currentLanguage;
    final total = sentimentStats.values.reduce((a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(
                      color: AppColors.positive,
                      value: sentimentStats['positive']!.toDouble(),
                      title: '${((sentimentStats['positive']! / total) * 100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppColors.negative,
                      value: sentimentStats['negative']!.toDouble(),
                      title: '${((sentimentStats['negative']! / total) * 100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppColors.neutral,
                      value: sentimentStats['neutral']!.toDouble(),
                      title: '${((sentimentStats['neutral']! / total) * 100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(
                  color: AppColors.positive,
                  label: AppLocalization.translate('positive', languageCode),
                  value: sentimentStats['positive']!,
                ),
                _LegendItem(
                  color: AppColors.negative,
                  label: AppLocalization.translate('negative', languageCode),
                  value: sentimentStats['negative']!,
                ),
                _LegendItem(
                  color: AppColors.neutral,
                  label: AppLocalization.translate('neutral', languageCode),
                  value: sentimentStats['neutral']!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}

