import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mahayatri_app/app.dart';

void main() {
  testWidgets('MahayatriApp renders without crashing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MahayatriApp(),
      ),
    );

    // Verify the app renders
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
