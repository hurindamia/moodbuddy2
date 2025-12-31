import 'package:flutter_test/flutter_test.dart';
import 'package:moodbuddy2/main.dart';

void main() {
  testWidgets('MoodBuddy app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MoodBuddyApp());

    // Just verify the app builds without crashing
    expect(find.byType(MoodBuddyApp), findsOneWidget);
  });
}
