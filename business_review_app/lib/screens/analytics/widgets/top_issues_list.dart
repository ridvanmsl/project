/// Top issues list widget
import 'package:flutter/material.dart';
import '../../../models/analytics.dart';
import '../../../models/review.dart';
import '../../../services/api_service.dart';

class TopIssuesList extends StatelessWidget {
  final List<TopIssue> issues;
  final String businessId;

  const TopIssuesList({
    super.key,
    required this.issues,
    required this.businessId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: issues.map((issue) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _showIssueDetails(context, issue, businessId),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          issue.count.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Text(
                          'issues',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          issue.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${issue.count} complaint${issue.count > 1 ? "s" : ""} detected',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showIssueDetails(BuildContext context, TopIssue issue, String businessId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _IssueDetailsSheet(
        issue: issue,
        businessId: businessId,
      ),
    );
  }
}

/// Separate stateful widget for issue details to fetch reviews dynamically
class _IssueDetailsSheet extends StatefulWidget {
  final TopIssue issue;
  final String businessId;

  const _IssueDetailsSheet({
    required this.issue,
    required this.businessId,
  });

  @override
  State<_IssueDetailsSheet> createState() => _IssueDetailsSheetState();
}

class _IssueDetailsSheetState extends State<_IssueDetailsSheet> {
  List<Review> _reviews = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ApiService();
      
      final reviews = await apiService.fetchReviews(
        widget.businessId,
        sentiment: 'negative',
        category: widget.issue.category,
      );

      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load reviews: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.issue.displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.issue.count} complaints',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: Colors.red.shade300),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                style: TextStyle(color: Colors.red.shade700),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadReviews,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _reviews.isEmpty
                        ? const Center(
                            child: Text('No reviews found for this issue'),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _reviews.length,
                            itemBuilder: (context, index) {
                              final review = _reviews[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.orange.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              widget.issue.category,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            review.customerName ?? 'Anonymous',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '"${review.text}"',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      if (review.date != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          review.date.toString().split(' ')[0],
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}


