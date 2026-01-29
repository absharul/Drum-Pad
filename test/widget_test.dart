// Basic widget test for Drum Pad app

import 'package:flutter_test/flutter_test.dart';
import 'package:drum_pad/main.dart';

void main() {
  testWidgets('Drum Pad app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DrumPadApp());

    // Verify that the app title is displayed
    expect(find.textContaining('DRUM PAD'), findsOneWidget);
  });
}
