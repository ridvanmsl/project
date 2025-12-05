import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localization.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';
import '../../models/review.dart';
import 'widgets/review_list_item.dart';
import 'widgets/filter_chip_widget.dart';

/// Reviews screen showing all customer reviews
class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  String _selectedFilter = 'all'; // 'all', 'positive', 'negative', 'neutral'
  String _searchQuery = '';
  List<Review> _allReviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final businessId = authProvider.businessId ?? 'amazon_business';

      // Clear old cache first
      await DatabaseService().clearAllReviews();

      final apiService = ApiService();
      final reviews = await apiService.fetchReviews(businessId);

      // Save new data to cache
      for (var review in reviews) {
        await DatabaseService().insertReview(review, businessId);
      }

      setState(() {
        _allReviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reviews from API: $e');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final businessId = authProvider.businessId ?? 'amazon_business';

      // Use cached data as fallback
      final localReviews = await DatabaseService().getReviewsForBusiness(businessId);

      setState(() {
        _allReviews = localReviews;
        _isLoading = false;
      });
    }
  }

  List<Review> get _filteredReviews {
    var reviews = _allReviews;

    // Apply sentiment filter
    if (_selectedFilter != 'all') {
      reviews = reviews.where((review) {
        return review.overallSentiment == _selectedFilter;
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      reviews = reviews.where((review) {
        return review.text.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            review.customerName
                ?.toLowerCase()
                .contains(_searchQuery.toLowerCase()) ==
            true;
      }).toList();
    }

    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<LanguageProvider>().currentLanguage;
    final authProvider = context.watch<AuthProvider>();
    final filteredReviews = _filteredReviews;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(authProvider.businessName ?? 'Reviews'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _loadReviews,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: AppLocalization.translate('search_reviews', languageCode),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                FilterChipWidget(
                  label: 'All',
                  isSelected: _selectedFilter == 'all',
                  onSelected: () => setState(() => _selectedFilter = 'all'),
                  count: _allReviews.length,
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: AppLocalization.translate('positive', languageCode),
                  isSelected: _selectedFilter == 'positive',
                  onSelected: () => setState(() => _selectedFilter = 'positive'),
                  color: AppColors.positive,
                  count: _allReviews.where((r) => r.isPositive).length,
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: AppLocalization.translate('negative', languageCode),
                  isSelected: _selectedFilter == 'negative',
                  onSelected: () => setState(() => _selectedFilter = 'negative'),
                  color: AppColors.negative,
                  count: _allReviews.where((r) => r.isNegative).length,
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: AppLocalization.translate('neutral', languageCode),
                  isSelected: _selectedFilter == 'neutral',
                  onSelected: () => setState(() => _selectedFilter = 'neutral'),
                  color: AppColors.neutral,
                  count: _allReviews.where((r) => r.isNeutral).length,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Reviews List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadReviews,
              child: filteredReviews.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalization.translate('no_reviews', languageCode),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Submit reviews via web interface',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: filteredReviews.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ReviewListItem(review: filteredReviews[index]),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

