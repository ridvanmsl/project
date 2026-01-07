/// Localization keys and translations for the application
class AppLocalization {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Business Analytics',
      'welcome': 'Welcome',
      'logout': 'Logout',
      'settings': 'Settings',
      'language': 'Language',
      'save': 'Save',
      'cancel': 'Cancel',
      'account': 'Account',
      'app_info': 'App Info',
      'version': 'Version',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'logout_confirm': 'Are you sure you want to logout?',
      
      'login_title': 'Welcome Back',
      'login_subtitle': 'Sign in to your business account',
      'email': 'Email',
      'password': 'Password',
      'login': 'Login',
      'forgot_password': 'Forgot Password?',
      'email_hint': 'Enter your email',
      'password_hint': 'Enter your password',
      
      'dashboard': 'Dashboard',
      'reviews': 'Reviews',
      'analytics': 'Analytics',
      'overview': 'Overview',
      'total_reviews': 'Total Reviews',
      'positive_reviews': 'Positive',
      'negative_reviews': 'Negative',
      'neutral_reviews': 'Neutral',
      'sentiment_distribution': 'Sentiment Distribution',
      'recent_reviews': 'Recent Reviews',
      'view_all': 'View All',
      
      'all_reviews': 'All Reviews',
      'search_reviews': 'Search reviews...',
      'filter': 'Filter',
      'sort': 'Sort',
      'no_reviews': 'No reviews found',
      
      'review_detail': 'Review Details',
      'sentiment_analysis': 'Sentiment Analysis',
      'aspects': 'Aspects',
      'category': 'Category',
      'sentiment': 'Sentiment',
      'aspect_term': 'Aspect Term',
      'date': 'Date',
      'rating': 'Rating',
      'review': 'Review',
      'overall_sentiment': 'Overall Sentiment',
      
      'positive': 'Positive',
      'negative': 'Negative',
      'neutral': 'Neutral',
      
      'food_quality': 'Food Quality',
      'service_general': 'Service',
      'ambience_general': 'Ambience',
      'price': 'Price',
      'location_general': 'Location',
      'restaurant_general': 'General',
      'hotel_general': 'General',
      'room_amenities': 'Room Amenities',
      'facilities_general': 'Facilities',
      
      'today': 'Today',
      'yesterday': 'Yesterday',
      'days_ago': 'days ago',
      'weeks_ago': 'weeks ago',
    },

  };
  
  static String translate(String key, String languageCode) {
    return _localizedValues[languageCode]?[key] ?? key;
  }
}

