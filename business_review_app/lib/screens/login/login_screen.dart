import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localization.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/api_service.dart';
import 'widgets/language_selector.dart';

/// Login screen with email/password authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  List<Map<String, String>> _demoAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadDemoAccounts();
  }

  Future<void> _loadDemoAccounts() async {
    try {
      final apiService = ApiService();
      final accounts = await apiService.getDemoAccounts();
      if (mounted) {
        setState(() {
          _demoAccounts = accounts;
        });
      }
      
      // If no accounts loaded, show error message
      if (accounts.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot connect to server. Make sure backend is running at http://localhost:8000'),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error loading demo accounts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend connection error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectAccount(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _translate('invalid_credentials') ?? 'Invalid credentials',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String? _translate(String key) {
    final languageCode = context.read<LanguageProvider>().currentLanguage;
    return AppLocalization.translate(key, languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final languageCode = context.watch<LanguageProvider>().currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height - MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                // Language Selector
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      LanguageSelector(),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo/Icon
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.analytics_rounded,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Title
                            Text(
                              AppLocalization.translate('login_title', languageCode),
                              style: Theme.of(context).textTheme.displayMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            // Subtitle
                            Text(
                              AppLocalization.translate('login_subtitle', languageCode),
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 48),

                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: AppLocalization.translate('email', languageCode),
                                hintText: AppLocalization.translate('email_hint', languageCode),
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: AppLocalization.translate('password', languageCode),
                                hintText: AppLocalization.translate('password_hint', languageCode),
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        AppLocalization.translate('login', languageCode),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Demo Accounts
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.info.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 20,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Demo Accounts (Tap to use)',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (_demoAccounts.isEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.warning_rounded, color: Colors.orange),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Cannot connect to backend',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Try manual login or start the backend:',
                                            style: TextStyle(fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Food: food@business.com / food123',
                                                  style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                                                ),
                                                Text(
                                                  'Course: coursera@business.com / coursera123',
                                                  style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                                                ),
                                                Text(
                                                  'Hotel: hotel@business.com / hotel123',
                                                  style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    ..._demoAccounts.map((account) {
                                      IconData icon;
                                      Color color;
                                      String label;
                                      
                                      // Use businessType from API (amazon, coursera, hotel)
                                      final businessType = account['businessType'] ?? '';
                                      
                                      if (businessType == 'amazon') {
                                        icon = Icons.restaurant_rounded;
                                        color = Colors.orange;
                                        label = account['businessName'] ?? 'Food Restaurant';
                                      } else if (businessType == 'coursera') {
                                        icon = Icons.school_rounded;
                                        color = Colors.blue;
                                        label = account['businessName'] ?? 'Online Course';
                                      } else {
                                        icon = Icons.hotel_rounded;
                                        color = Colors.green;
                                        label = account['businessName'] ?? 'Hotel';
                                      }
                                      
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: InkWell(
                                          onTap: () => _selectAccount(
                                            account['email']!,
                                            account['password']!,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: color.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: color.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(icon, color: color, size: 24),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        label,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        account['email']!,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey.shade600,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Password: ${account['password']}',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.grey.shade500,
                                                          fontFamily: 'monospace',
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

