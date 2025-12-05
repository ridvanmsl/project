import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localization.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';

/// Settings screen with language and account options
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<LanguageProvider>().currentLanguage;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalization.translate('settings', languageCode)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            Text(
              AppLocalization.translate('account', languageCode),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.business_rounded,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProvider.businessName ?? 'Business Name',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authProvider.userEmail ?? 'email@example.com',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Language Section
            Text(
              AppLocalization.translate('language', languageCode),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  const _LanguageOption(
                    languageCode: 'en',
                    languageName: 'English',
                    icon: '🇬🇧',
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.textSecondary.withOpacity(0.1),
                  ),
                  const _LanguageOption(
                    languageCode: 'tr',
                    languageName: 'Türkçe',
                    icon: '🇹🇷',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // App Info Section
            Text(
              AppLocalization.translate('app_info', languageCode),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                    ),
                    title: Text(AppLocalization.translate('version', languageCode)),
                    trailing: const Text('1.0.0'),
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.textSecondary.withOpacity(0.1),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(AppLocalization.translate('privacy_policy', languageCode)),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      // Navigate to privacy policy
                    },
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.textSecondary.withOpacity(0.1),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(AppLocalization.translate('terms_of_service', languageCode)),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      // Navigate to terms of service
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        AppLocalization.translate('logout', languageCode),
                      ),
                      content: Text(
                        AppLocalization.translate('logout_confirm', languageCode),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppLocalization.translate('cancel', languageCode),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.read<AuthProvider>().logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          child: Text(
                            AppLocalization.translate('logout', languageCode),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded),
                    const SizedBox(width: 8),
                    Text(AppLocalization.translate('logout', languageCode)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String languageCode;
  final String languageName;
  final String icon;

  const _LanguageOption({
    required this.languageCode,
    required this.languageName,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final currentLanguage = context.watch<LanguageProvider>().currentLanguage;
    final isSelected = currentLanguage == languageCode;

    return ListTile(
      onTap: () {
        context.read<LanguageProvider>().changeLanguage(languageCode);
      },
      leading: Text(
        icon,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(
        languageName,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
            )
          : null,
    );
  }
}
