import 'package:flutter_test/flutter_test.dart';
import 'package:auto_tap/main.dart';

void main() {
  testWidgets('App renders clicker home page', (WidgetTester tester) async {
    await tester.pumpWidget(const ClickerApp());
    expect(find.text('屏幕点击器'), findsOneWidget);
    expect(find.text('开始点击'), findsOneWidget);
  });
}
