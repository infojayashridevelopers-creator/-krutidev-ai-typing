import 'package:flutter_test/flutter_test.dart';
import 'package:krutidev_ai_typing/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KrutiDevApp());
    expect(find.byType(KrutiDevApp), findsOneWidget);
  });
}
