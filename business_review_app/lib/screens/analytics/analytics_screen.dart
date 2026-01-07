/// AI-powered analytics dashboard for business insights
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';
import '../../models/analytics.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localization.dart';
import '../../providers/language_provider.dart';
import 'widgets/analytics_card.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/category_chart.dart';
import 'widgets/top_issues_list.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'daily';
  bool _isLoading = false;
  String? _errorMessage;
  Analytics? _analytics;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final businessId = authProvider.businessId ?? 'amazon_business';

      final apiService = ApiService();
      final analytics = await apiService.fetchAnalytics(businessId, _selectedPeriod);

      if (analytics != null) {
        await DatabaseService().insertAnalytics(analytics);
      }

      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final businessId = authProvider.businessId ?? 'amazon_business';
      
      final localAnalytics = await DatabaseService()
          .getLatestAnalytics(businessId, _selectedPeriod);

      setState(() {
        _analytics = localAnalytics;
        _errorMessage = 'Using cached data. Could not connect to server.';
        _isLoading = false;
      });
    }
  }

  void _changePeriod(String period) {
    if (period != _selectedPeriod) {
      setState(() {
        _selectedPeriod = period;
      });
      _loadAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<LanguageProvider>().currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalization.translate('analytics', languageCode)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _loadAnalytics,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAnalytics,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade100,
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: Colors.orange.shade900),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.orange.shade900),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildAnalyticsContent()),
        ],
      );
    }

    return _buildAnalyticsContent();
  }

  Widget _buildAnalyticsContent() {
    if (_analytics == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No analytics available yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Submit reviews to generate insights',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 20),
          _buildSummaryCards(_analytics!),
          const SizedBox(height: 24),
          _buildRecommendations(_analytics!),
          const SizedBox(height: 24),
          _buildTopIssues(_analytics!),
          const SizedBox(height: 24),
          _buildCategoryBreakdown(_analytics!),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        const Text(
          'Period:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              _buildPeriodChip('Daily', 'daily'),
              const SizedBox(width: 8),
              _buildPeriodChip('Weekly', 'weekly'),
              const SizedBox(width: 8),
              _buildPeriodChip('Monthly', 'monthly'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodChip(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: ChoiceChip(
        label: SizedBox(
          width: double.infinity,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
          ),
        ),
        selected: isSelected,
        onSelected: (_) => _changePeriod(period),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  Widget _buildSummaryCards(Analytics analytics) {
    return Row(
      children: [
        Expanded(
          child: AnalyticsCard(
            title: 'Total Reviews',
            value: analytics.totalReviews.toString(),
            icon: Icons.rate_review_rounded,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnalyticsCard(
            title: 'Positive',
            value: analytics.positiveCount.toString(),
            icon: Icons.thumb_up_rounded,
            color: Colors.green,
            subtitle: '${analytics.positivePercentage.toStringAsFixed(0)}%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnalyticsCard(
            title: 'Negative',
            value: analytics.negativeCount.toString(),
            icon: Icons.thumb_down_rounded,
            color: Colors.red,
            subtitle: '${analytics.negativePercentage.toStringAsFixed(0)}%',
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(Analytics analytics) {
    if (analytics.recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Recommendations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...analytics.recommendations.map((rec) => RecommendationCard(
              recommendation: rec,
            )),
      ],
    );
  }

  Widget _buildTopIssues(Analytics analytics) {
    if (analytics.topIssues.isEmpty) {
      return const SizedBox.shrink();
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Issues Detected',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TopIssuesList(
          issues: analytics.topIssues,
          businessId: authProvider.businessId ?? 'amazon_business',
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(Analytics analytics) {
    if (analytics.categoryBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Performance',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        CategoryChart(breakdown: analytics.categoryBreakdown),
      ],
    );
  }
}

