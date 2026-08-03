import 'package:flutter_test/flutter_test.dart';
import 'package:xp_dart_example/main.dart';

void main() {
  testWidgets('XPExampleApp renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const XPExampleApp());
    expect(find.text('XP.css (ported to xp_dart)'), findsOneWidget);
  });
}
