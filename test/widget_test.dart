// This is a basic Flutter widget test for the Proxy Detector app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proxy_detector/main.dart';

void main() {
  testWidgets('Proxy Detector app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProxyDetectorApp());

    // Verify that the app title is displayed.
    expect(find.text('Windows プロキシ設定検出'), findsOneWidget);

    // Verify that the refresh button is present.
    expect(find.byIcon(Icons.refresh), findsOneWidget);

    // Verify that the loading indicator or content is displayed.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
