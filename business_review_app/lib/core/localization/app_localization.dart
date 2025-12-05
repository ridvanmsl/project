/// Localization keys and translations for the application
class AppLocalization {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General
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
      
      // Login Screen
      'login_title': 'Welcome Back',
      'login_subtitle': 'Sign in to your business account',
      'email': 'Email',
      'password': 'Password',
      'login': 'Login',
      'forgot_password': 'Forgot Password?',
      'email_hint': 'Enter your email',
      'password_hint': 'Enter your password',
      
      // Dashboard
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
      
      // Reviews Screen
      'all_reviews': 'All Reviews',
      'search_reviews': 'Search reviews...',
      'filter': 'Filter',
      'sort': 'Sort',
      'no_reviews': 'No reviews found',
      
      // Review Detail
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
      
      // Sentiment Types
      'positive': 'Positive',
      'negative': 'Negative',
      'neutral': 'Neutral',
      
      // Categories
      'food_quality': 'Food Quality',
      'service_general': 'Service',
      'ambience_general': 'Ambience',
      'price': 'Price',
      'location_general': 'Location',
      'restaurant_general': 'General',
      'hotel_general': 'General',
      'room_amenities': 'Room Amenities',
      'facilities_general': 'Facilities',
      
      // Time
      'today': 'Today',
      'yesterday': 'Yesterday',
      'days_ago': 'days ago',
      'weeks_ago': 'weeks ago',
    },
    'tr': {
      // General
      'app_name': 'İşletme Analizi',
      'welcome': 'Hoş Geldiniz',
      'logout': 'Çıkış Yap',
      'settings': 'Ayarlar',
      'language': 'Dil',
      'save': 'Kaydet',
      'cancel': 'İptal',
      'account': 'Hesap',
      'app_info': 'Uygulama Bilgisi',
      'version': 'Sürüm',
      'privacy_policy': 'Gizlilik Politikası',
      'terms_of_service': 'Kullanım Koşulları',
      'logout_confirm': 'Çıkış yapmak istediğinizden emin misiniz?',
      
      // Login Screen
      'login_title': 'Tekrar Hoş Geldiniz',
      'login_subtitle': 'İşletme hesabınıza giriş yapın',
      'email': 'E-posta',
      'password': 'Şifre',
      'login': 'Giriş Yap',
      'forgot_password': 'Şifremi Unuttum?',
      'email_hint': 'E-posta adresinizi girin',
      'password_hint': 'Şifrenizi girin',
      
      // Dashboard
      'dashboard': 'Ana Sayfa',
      'reviews': 'Yorumlar',
      'analytics': 'Analitik',
      'overview': 'Genel Bakış',
      'total_reviews': 'Toplam Yorum',
      'positive_reviews': 'Olumlu',
      'negative_reviews': 'Olumsuz',
      'neutral_reviews': 'Nötr',
      'sentiment_distribution': 'Duygu Dağılımı',
      'recent_reviews': 'Son Yorumlar',
      'view_all': 'Tümünü Gör',
      
      // Reviews Screen
      'all_reviews': 'Tüm Yorumlar',
      'search_reviews': 'Yorum ara...',
      'filter': 'Filtrele',
      'sort': 'Sırala',
      'no_reviews': 'Yorum bulunamadı',
      
      // Review Detail
      'review_detail': 'Yorum Detayı',
      'sentiment_analysis': 'Duygu Analizi',
      'aspects': 'Yönler',
      'category': 'Kategori',
      'sentiment': 'Duygu',
      'aspect_term': 'Yön Terimi',
      'date': 'Tarih',
      'rating': 'Değerlendirme',
      'review': 'Yorum',
      'overall_sentiment': 'Genel Duygu',
      
      // Sentiment Types
      'positive': 'Olumlu',
      'negative': 'Olumsuz',
      'neutral': 'Nötr',
      
      // Categories
      'food_quality': 'Yemek Kalitesi',
      'service_general': 'Hizmet',
      'ambience_general': 'Ortam',
      'price': 'Fiyat',
      'location_general': 'Konum',
      'restaurant_general': 'Genel',
      'hotel_general': 'Genel',
      'room_amenities': 'Oda Olanakları',
      'facilities_general': 'Tesisler',
      
      // Time
      'today': 'Bugün',
      'yesterday': 'Dün',
      'days_ago': 'gün önce',
      'weeks_ago': 'hafta önce',
    },
  };
  
  static String translate(String key, String languageCode) {
    return _localizedValues[languageCode]?[key] ?? key;
  }
}

