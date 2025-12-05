import 'package:flutter_test/flutter_test.dart';

import 'package:business_review_app/main.dart';

void main() {
  testWidgets('App launches with login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that login screen is shown
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
