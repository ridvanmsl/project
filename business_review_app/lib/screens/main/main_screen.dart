import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localization.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/websocket_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../reviews/reviews_screen.dart';
import '../analytics/analytics_screen.dart';
import '../settings/settings_screen.dart';

/// Main screen with bottom navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String? _lastNotificationTime;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ReviewsScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wsProvider = context.read<WebSocketProvider>();
      final authProvider = context.read<AuthProvider>();
      
      final businessId = authProvider.businessId;
      if (businessId != null) {
        wsProvider.initWithBusinessId(businessId);
      }
      
      wsProvider.addListener(_handleWebSocketNotification);
    });
  }

  @override
  void dispose() {
    final wsProvider = context.read<WebSocketProvider>();
    wsProvider.removeListener(_handleWebSocketNotification);
    super.dispose();
  }

  /// Handle incoming WebSocket notifications
  void _handleWebSocketNotification() {
    final wsProvider = context.read<WebSocketProvider>();
    final notification = wsProvider.lastNotification;
    final notificationTime = wsProvider.lastNotificationTime;
    
    if (notification != null && 
        notificationTime != null &&
        _lastNotificationTime != notificationTime.toString()) {
      _lastNotificationTime = notificationTime.toString();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notification_important, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'New Review!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      notification,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              setState(() => _currentIndex = 1);
            },
          ),
        ),
      );
      
      wsProvider.clearNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<LanguageProvider>().currentLanguage;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: AppLocalization.translate('dashboard', languageCode),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.rate_review_rounded),
              label: AppLocalization.translate('reviews', languageCode),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.analytics_rounded),
              label: AppLocalization.translate('analytics', languageCode),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              label: AppLocalization.translate('settings', languageCode),
            ),
          ],
        ),
      ),
    );
  }
}

