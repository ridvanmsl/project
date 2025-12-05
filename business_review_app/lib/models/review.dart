/// Review model representing a customer review with sentiment analysis
class Review {
  final String id;
  final String text;
  final DateTime date;
  final List<AspectSentiment> aspects;
  final String? customerName;
  final double? rating;
  final String? _overallSentimentFromAPI;
  
  Review({
    required this.id,
    required this.text,
    required this.date,
    required this.aspects,
    this.customerName,
    this.rating,
    String? overallSentiment,
  }) : _overallSentimentFromAPI = overallSentiment;
  
  /// Get overall sentiment - use API value if available, otherwise calculate from aspects
  String get overallSentiment {
    if (_overallSentimentFromAPI != null && _overallSentimentFromAPI!.isNotEmpty) {
      return _overallSentimentFromAPI!;
    }
    
    if (aspects.isEmpty) return 'neutral';
    
    final sentimentCounts = <String, int>{};
    for (var aspect in aspects) {
      sentimentCounts[aspect.sentiment] = 
          (sentimentCounts[aspect.sentiment] ?? 0) + 1;
    }
    
    // Return the most common sentiment
    return sentimentCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  /// Check if review is positive
  bool get isPositive => overallSentiment == 'positive';
  
  /// Check if review is negative
  bool get isNegative => overallSentiment == 'negative';
  
  /// Check if review is neutral
  bool get isNeutral => overallSentiment == 'neutral';
  
  /// Create Review from JSON (for API responses)
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'].toString(),
      text: json['text'] as String,
      date: DateTime.parse(json['date'] as String),
      aspects: (json['aspects'] as List?)
          ?.map((aspect) => AspectSentiment(
                aspectTerm: aspect['category'] ?? 'general', // Use category as term if aspect_term not available
                category: aspect['category'] ?? 'general',
                sentiment: aspect['sentiment'] ?? 'neutral',
              ))
          .toList() ?? [],
      customerName: json['customerName'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      overallSentiment: json['overallSentiment'] as String?,
    );
  }
  
  /// Convert Review to Map (for database storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'date': date.toIso8601String(),
      'customer_name': customerName,
      'rating': rating,
      'overall_sentiment': overallSentiment,
    };
  }
}

/// Aspect-based sentiment representing a specific aspect mentioned in a review
class AspectSentiment {
  final String aspectTerm;
  final String category;
  final String sentiment; // 'positive', 'negative', 'neutral'
  
  AspectSentiment({
    required this.aspectTerm,
    required this.category,
    required this.sentiment,
  });
  
  /// Create from triplet format [aspect_term, category, sentiment]
  factory AspectSentiment.fromList(List<String> triplet) {
    return AspectSentiment(
      aspectTerm: triplet[0],
      category: triplet[1],
      sentiment: triplet[2],
    );
  }
}

