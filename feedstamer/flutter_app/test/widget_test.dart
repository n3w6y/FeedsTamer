import 'package:flutter_test/flutter_test.dart';
import 'package:feedstamer/main.dart';

void main() {
  testWidgets('Splash screen displays and navigates to login screen', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const FeedsTamerApp());

    // Verify that the splash screen displays (assuming it has some identifiable content).
    // Replace 'FeedsTamer' with actual text or widget content from your SplashScreen.
    expect(find.text('FeedsTamer'), findsOneWidget); // Adjust based on your SplashScreen content

    // Wait for the splash screen delay (e.g., 3 seconds) and trigger a frame.
    // Adjust the duration to match your splash screen's delay.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that the app navigates to the LoginScreen (stubbed earlier).
    expect(find.text('Login Screen (Stub)'), findsOneWidget);
  });
}