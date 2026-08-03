import 'package:flutter_test/flutter_test.dart';
import 'package:xp_dart/xp_dart.dart';

void main() {
  test('XPColors and XPThemeData initialization test', () {
    const theme = XPThemeData();
    expect(theme.surface, XPColors.surface);
    expect(theme.dialogBlue, XPColors.dialogBlue);
  });
}
