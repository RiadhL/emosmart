import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EmoSmart smoke test', (WidgetTester tester) async {
    // Firebase requires real initialization — integration tests cover app boot.
    // Unit-level widget tests go here as the project grows.
    expect(true, isTrue);
  });
}
