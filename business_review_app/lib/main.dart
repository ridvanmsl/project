import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login/login_screen.dart';
import 'screens/main/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Business Review Analytics',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: Locale(languageProvider.currentLanguage),
            supportedLocales: const [
              Locale('en'),
              Locale('tr'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return authProvider.isAuthenticated
                    ? const MainScreen()
                    : const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
