import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localization.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/review.dart';
import '../reviews/reviews_screen.dart';
import 'widgets/stat_card.dart';
import 'widgets/sentiment_chart.dart';
import 'widgets/recent_review_card.dart';

/// Dashboard screen showing business analytics and overview
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final businessId = authProvider.businessId ?? 'amazon_business';

      final apiService = ApiService();
      final reviews = await apiService.fetchReviews(businessId);

      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Map<String, int> get _sentimentStats {
    final stats = {'positive': 0, 'negative': 0, 'neutral': 0};
    for (var review in _reviews) {
      stats[review.overallSentiment] =
          (stats[review.overallSentiment] ?? 0) + 1;
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<LanguageProvider>().currentLanguage;
    final businessName =
        context.watch<AuthProvider>().businessName ?? 'Business';
    final sentimentStats = _sentimentStats;
    final recentReviews = _reviews.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalization.translate('dashboard', languageCode)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _loadData,
            tooltip: 'Refresh',
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.store_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  businessName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalization.translate('welcome', languageCode)}, $businessName!',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalization.translate('overview', languageCode),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: AppLocalization.translate(
                          'total_reviews', languageCode),
                      value: _reviews.length.toString(),
                      icon: Icons.rate_review_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: AppLocalization.translate(
                          'positive_reviews', languageCode),
                      value: sentimentStats['positive'].toString(),
                      icon: Icons.sentiment_satisfied_rounded,
                      color: AppColors.positive,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: AppLocalization.translate(
                          'negative_reviews', languageCode),
                      value: sentimentStats['negative'].toString(),
                      icon: Icons.sentiment_dissatisfied_rounded,
                      color: AppColors.negative,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: AppLocalization.translate(
                          'neutral_reviews', languageCode),
                      value: sentimentStats['neutral'].toString(),
                      icon: Icons.sentiment_neutral_rounded,
                      color: AppColors.neutral,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Text(
                AppLocalization.translate(
                    'sentiment_distribution', languageCode),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              SentimentChart(sentimentStats: sentimentStats),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalization.translate('recent_reviews', languageCode),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReviewsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      AppLocalization.translate('view_all', languageCode),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (recentReviews.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No reviews yet',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...recentReviews.map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: RecentReviewCard(review: review),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
