
import 'package:flutter_test/flutter_test.dart';

import 'package:exam_duty_app/main.dart'; // Use your real project name here

void main() {
  testWidgets('App loads and shows LoginScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ExamDutyApp()); // <-- This is your main app class

    // Verify that your login screen is present
    expect(find.text('ExamDuty+'), findsOneWidget);
    expect(find.text('BITS Email ID'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
