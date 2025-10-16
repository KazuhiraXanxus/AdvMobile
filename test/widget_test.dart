import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:constantino_advmobprog/main.dart';
import 'package:constantino_advmobprog/provider/theme_provider.dart';

void main() {
  group('Facebook Replication App Tests', () {
    testWidgets('App loads and shows Facebook title', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Facebook'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Search functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      
      expect(find.text('test'), findsOneWidget);
    });

    testWidgets('Settings navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('Theme toggle works in Settings', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      
      Switch themeSwitch = tester.widget(switchFinder);
      bool initialState = themeSwitch.value;
      
      await tester.tap(switchFinder);
      await tester.pump();
      
      themeSwitch = tester.widget(switchFinder);
      expect(themeSwitch.value, !initialState);
    });

    testWidgets('Articles load and display', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Clear search button works', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test search');
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      final TextField searchField = tester.widget(find.byType(TextField));
      expect(searchField.controller?.text, isEmpty);
    });
  });

  group('ThemeProvider Unit Tests', () {
    test('ThemeProvider toggles correctly', () {
      final themeProvider = ThemeProvider();
      
      expect(themeProvider.isDarkMode, false);
      
      themeProvider.toggleTheme();
      expect(themeProvider.isDarkMode, true);
      
      themeProvider.toggleTheme();
      expect(themeProvider.isDarkMode, false);
    });

    test('ThemeProvider setTheme works correctly', () {
      final themeProvider = ThemeProvider();
      
      themeProvider.setTheme(true);
      expect(themeProvider.isDarkMode, true);
      
      themeProvider.setTheme(false);
      expect(themeProvider.isDarkMode, false);
    });
  });
}