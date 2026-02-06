// Basic smoke test for Sathi financial app

import 'package:flutter_test/flutter_test.dart';
import 'package:fintech_sbmp/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const SathiApp());
    
    // Just verify the app can be built without errors
    expect(find.byType(SathiApp), findsOneWidget);
  });
}
