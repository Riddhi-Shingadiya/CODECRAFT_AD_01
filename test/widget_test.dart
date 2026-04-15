import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';

void main() {
  testWidgets('Calculator UI Test', (WidgetTester tester) async {
    // Load calculator app
    await tester.pumpWidget(const CalculatorApp());

    // Check initial display
    expect(find.text('0'), findsOneWidget);

    // Tap buttons: 2 + 3 =
    await tester.tap(find.text('2'));
    await tester.pump();

    await tester.tap(find.text('+'));
    await tester.pump();

    await tester.tap(find.text('3'));
    await tester.pump();

    await tester.tap(find.text('='));
    await tester.pump();

    // Verify result
    expect(find.text('5.0'), findsOneWidget);
  });
}