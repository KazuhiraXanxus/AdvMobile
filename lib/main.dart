import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/theme_provider.dart';
import 'screens/home_screen.dart';

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
            home: const HomeScreen(), // This loads the Facebook home screen
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}