import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/review.dart';
import '../../../providers/language_provider.dart';
import '../../reviews/review_detail_screen.dart';
import '../../../utils/date_formatter.dart';

/// Card displaying a recent review summary
class RecentReviewCard extends StatelessWidget {
  final Review review;

  const RecentReviewCard({
    super.key,
    required this.review,
  });

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return AppColors.positive;
      case 'negative':
        return AppColors.negative;
      case 'neutral':
        return AppColors.neutral;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getSentimentIcon(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Icons.sentiment_satisfied_rounded;
      case 'negative':
        return Icons.sentiment_dissatisfied_rounded;
      case 'neutral':
        return Icons.sentiment_neutral_rounded;
      default:
        return Icons.sentiment_neutral_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<LanguageProvider>().currentLanguage;
    final sentiment = review.overallSentiment;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewDetailScreen(review: review),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getSentimentColor(sentiment).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getSentimentIcon(sentiment),
                      color: _getSentimentColor(sentiment),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.customerName ?? 'Anonymous',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          DateFormatter.formatDate(review.date, languageCode),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  if (review.rating != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            review.rating!.toStringAsFixed(1),
                            style:
                                Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppColors.primary,
                                    ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                review.text,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: review.aspects.take(3).map((aspect) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getSentimentColor(aspect.sentiment).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getSentimentColor(aspect.sentiment).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      aspect.category.replaceAll('_', ' '),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _getSentimentColor(aspect.sentiment),
                            fontSize: 12,
                          ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

