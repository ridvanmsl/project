/// Analytics model for AI-generated business insights
import 'dart:convert';

class Analytics {
  final int? id;
  final String businessId;
  final String period;
  final DateTime analysisDate;
  final int totalReviews;
  final int positiveCount;
  final int negativeCount;
  final int neutralCount;
  final List<TopIssue> topIssues;
  final List<Recommendation> recommendations;
  final List<CategoryBreakdown> categoryBreakdown;

  Analytics({
    this.id,
    required this.businessId,
    required this.period,
    required this.analysisDate,
    required this.totalReviews,
    required this.positiveCount,
    required this.negativeCount,
    required this.neutralCount,
    required this.topIssues,
    required this.recommendations,
    required this.categoryBreakdown,
  });

  factory Analytics.fromMap(Map<String, dynamic> map) {
    List<dynamic> parseJsonList(dynamic data) {
      if (data is String) {
        return jsonDecode(data) as List;
      } else if (data is List) {
        return data;
      }
      return [];
    }

    return Analytics(
      id: map['id'] as int?,
      businessId: map['business_id'] ?? map['businessId'] ?? 'unknown',
      period: map['period'] ?? 'weekly',
      analysisDate: map['analysis_date'] != null 
          ? DateTime.parse(map['analysis_date'] as String)
          : DateTime.now(),
      totalReviews: map['total_reviews'] ?? map['totalReviews'] ?? 0,
      positiveCount: map['positive_count'] ?? map['positiveCount'] ?? 0,
      negativeCount: map['negative_count'] ?? map['negativeCount'] ?? 0,
      neutralCount: map['neutral_count'] ?? map['neutralCount'] ?? 0,
      topIssues: parseJsonList(map['top_issues'] ?? map['topIssues'] ?? [])
          .map((e) {
            if (e is Map<String, dynamic>) {
              return TopIssue.fromJson(e);
            } else if (e is Map) {
              return TopIssue.fromJson(Map<String, dynamic>.from(e));
            } else {
              return TopIssue.fromJson({'category': e.toString(), 'count': 0, 'examples': []});
            }
          })
          .toList(),
      recommendations: (map['recommendations'] is List 
          ? (map['recommendations'] as List)
          : parseJsonList(map['recommendations'] ?? []))
          .map((e) {
            if (e is String) {
              return Recommendation(
                priority: 'MEDIUM',
                title: 'Recommendation',
                description: e,
              );
            }
            return Recommendation.fromJson(e);
          })
          .toList(),
      categoryBreakdown: parseJsonList(map['category_breakdown'] ?? map['categoryBreakdown'] ?? [])
          .map((e) => CategoryBreakdown.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'period': period,
      'analysis_date': analysisDate.toIso8601String(),
      'total_reviews': totalReviews,
      'positive_count': positiveCount,
      'negative_count': negativeCount,
      'neutral_count': neutralCount,
      'top_issues': jsonEncode(topIssues.map((e) => e.toJson()).toList()),
      'recommendations':
          jsonEncode(recommendations.map((e) => e.toJson()).toList()),
      'category_breakdown':
          jsonEncode(categoryBreakdown.map((e) => e.toJson()).toList()),
    };
  }

  double get positivePercentage =>
      totalReviews > 0 ? (positiveCount / totalReviews) * 100 : 0;

  double get negativePercentage =>
      totalReviews > 0 ? (negativeCount / totalReviews) * 100 : 0;

  double get neutralPercentage =>
      totalReviews > 0 ? (neutralCount / totalReviews) * 100 : 0;
}

class TopIssue {
  final String category;
  final int count;
  final List<IssueExample> examples;

  TopIssue({
    required this.category,
    required this.count,
    required this.examples,
  });

  factory TopIssue.fromJson(Map<String, dynamic> json) {
    return TopIssue(
      category: json['category'] as String,
      count: (json['count'] as num?)?.toInt() ?? 0,
      examples: (json['examples'] as List?)
          ?.map((e) => IssueExample.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'count': count,
      'examples': examples.map((e) => e.toJson()).toList(),
    };
  }

  String get displayName => category.replaceAll('_', ' ').toUpperCase();
}

class IssueExample {
  final String term;
  final String reviewText;

  IssueExample({required this.term, required this.reviewText});

  factory IssueExample.fromJson(Map<String, dynamic> json) {
    return IssueExample(
      term: json['term'] as String,
      reviewText: json['review_text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'term': term,
      'review_text': reviewText,
    };
  }
}

class Recommendation {
  final String priority;
  final String title;
  final String description;

  Recommendation({
    required this.priority,
    required this.title,
    required this.description,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      priority: json['priority'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priority': priority,
      'title': title,
      'description': description,
    };
  }

  bool get isHighPriority => priority == 'HIGH';
  bool get isMediumPriority => priority == 'MEDIUM';
  bool get isLowPriority => priority == 'LOW';
}

class CategoryBreakdown {
  final String category;
  final int total;
  final double positivePct;
  final double negativePct;
  final double neutralPct;

  CategoryBreakdown({
    required this.category,
    required this.total,
    required this.positivePct,
    required this.negativePct,
    required this.neutralPct,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    final name = json['name'] ?? json['category'] ?? 'Unknown';
    final positive = json['positive'] ?? 0;
    final negative = json['negative'] ?? 0;
    final neutral = json['neutral'] ?? 0;
    final total = json['total'] ?? (positive + negative + neutral);
    
    return CategoryBreakdown(
      category: name,
      total: total is int ? total : (total as num).toInt(),
      positivePct: json['positive_pct'] != null 
          ? (json['positive_pct'] as num).toDouble()
          : (total > 0 ? (positive / total * 100) : 0.0),
      negativePct: json['negative_pct'] != null
          ? (json['negative_pct'] as num).toDouble()
          : (total > 0 ? (negative / total * 100) : 0.0),
      neutralPct: json['neutral_pct'] != null
          ? (json['neutral_pct'] as num).toDouble()
          : (total > 0 ? (neutral / total * 100) : 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'total': total,
      'positive_pct': positivePct,
      'negative_pct': negativePct,
      'neutral_pct': neutralPct,
    };
  }

  String get displayName => category.replaceAll('_', ' ').toUpperCase();
}

