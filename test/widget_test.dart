import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasar_malam/core/providers/theme_provider.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/dashboard/presentation/providers/product_provider.dart';
import 'package:pasar_malam/main.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App shows splash loading on first frame', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  test('ThemeProvider toggles light and dark mode', () {
    final provider = ThemeProvider();

    expect(provider.isDark, isFalse);
    expect(provider.themeMode, ThemeMode.light);

    provider.toggle();

    expect(provider.isDark, isTrue);
    expect(provider.themeMode, ThemeMode.dark);
  });
}
