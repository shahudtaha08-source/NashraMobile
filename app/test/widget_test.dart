import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meri_nashra/main.dart';

void main() {
  testWidgets('Nashra chat screen loads and sends a message',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NashraApp());

    expect(find.text('Meri Nashra'), findsOneWidget);
    expect(find.text('Your personal companion'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'Hello Nashra',
    );

    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Hello Nashra'), findsOneWidget);
    expect(
      find.text(
        "I'm here. AI connection will be added in a later step.",
      ),
      findsOneWidget,
    );
  });
}
