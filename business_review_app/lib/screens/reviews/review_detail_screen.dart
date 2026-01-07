import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localization.dart';
import '../../providers/language_provider.dart';
import '../../models/review.dart';
import '../../utils/date_formatter.dart';

/// Detailed view of a single review with aspect analysis
class ReviewDetailScreen extends StatelessWidget {
  final Review review;

  const ReviewDetailScreen({
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalization.translate('review_detail', languageCode)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: _getSentimentColor(sentiment).withOpacity(0.1),
                          child: Icon(
                            _getSentimentIcon(sentiment),
                            color: _getSentimentColor(sentiment),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.customerName ?? 'Anonymous',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormatter.formatDateTime(review.date),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (review.rating != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 24,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              review.rating!.toStringAsFixed(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ 5.0',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getSentimentColor(sentiment).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getSentimentIcon(sentiment),
                          color: _getSentimentColor(sentiment),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalization.translate('overall_sentiment', languageCode),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalization.translate(sentiment, languageCode),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: _getSentimentColor(sentiment),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalization.translate('review', languageCode),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        review.text,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalization.translate('sentiment_analysis', languageCode),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${review.aspects.length} ${AppLocalization.translate('aspects', languageCode).toLowerCase()}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  ...review.aspects.map((aspect) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getSentimentColor(aspect.sentiment),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    aspect.aspectTerm == 'NULL'
                                        ? 'General'
                                        : aspect.aspectTerm,
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getSentimentColor(aspect.sentiment)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getSentimentIcon(aspect.sentiment),
                                        size: 16,
                                        color: _getSentimentColor(aspect.sentiment),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppLocalization.translate(
                                          aspect.sentiment,
                                          languageCode,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: _getSentimentColor(
                                                aspect.sentiment,
                                              ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${AppLocalization.translate('category', languageCode)}: ',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  aspect.category.replaceAll('_', ' '),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

