import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/review.dart';
import '../../../providers/language_provider.dart';
import '../../../utils/date_formatter.dart';
import '../review_detail_screen.dart';

/// List item widget for displaying a review
class ReviewListItem extends StatelessWidget {
  final Review review;

  const ReviewListItem({
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
              // Header
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundColor: _getSentimentColor(sentiment).withOpacity(0.1),
                    child: Icon(
                      _getSentimentIcon(sentiment),
                      color: _getSentimentColor(sentiment),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Customer Name & Date
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

                  // Rating
                  if (review.rating != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 18,
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

              // Review Text
              Text(
                review.text,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Aspects Count
              Row(
                children: [
                  Icon(
                    Icons.label_outline,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${review.aspects.length} aspects analyzed',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

