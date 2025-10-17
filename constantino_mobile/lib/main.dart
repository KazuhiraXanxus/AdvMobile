import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Facebook Replication',
            theme: ThemeData(
              useMaterial3: true,
              brightness: themeProvider.isDarkMode 
                  ? Brightness.dark 
                  : Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1877F2), // Facebook blue
                brightness: themeProvider.isDarkMode 
                    ? Brightness.dark 
                    : Brightness.light,
              ),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}