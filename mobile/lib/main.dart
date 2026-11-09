import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_settings.dart';
import 'state/auth_session.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const CareCompanionApp());
}

class CareCompanionApp extends StatelessWidget {
  const CareCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettings()),
        ChangeNotifierProvider(create: (_) => AuthSession()),
      ],
      child: Consumer<AppSettings>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Care Companion',
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, brightness: Brightness.dark),
            ),
            home: Builder(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: settings.textScale),
                  child: const SplashScreen(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
