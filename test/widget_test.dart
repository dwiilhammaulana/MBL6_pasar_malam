import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasar_malam/main.dart';

void main() {
  testWidgets('App shows splash loading on first frame', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
