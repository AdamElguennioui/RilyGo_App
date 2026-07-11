import 'package:flutter_test/flutter_test.dart';
import 'package:rily_app/main.dart';

void main() {
  testWidgets('MyApp se lance correctement', (WidgetTester tester) async {
    await tester.pumpWidget(RilyApp());

    expect(find.text('Login OTP'), findsOneWidget);
  });
}