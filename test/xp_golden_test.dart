import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xp_dart/xp_dart.dart';

Widget _buildGoldenApp(Widget child, {Size size = const Size(800, 600)}) {
  return WidgetsApp(
    color: XPColors.surface,
    onGenerateRoute: (settings) {
      return PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) {
          return XPSurface(
            width: size.width,
            height: size.height,
            child: Center(child: child),
          );
        },
      );
    },
  );
}

void main() {
  testWidgets('XPWindow Golden Test', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 400));

    await tester.pumpWidget(
      _buildGoldenApp(
        const XPWindow(
          width: 400,
          height: 300,
          titleText: 'My First Program',
          statusBar: XPStatusBar(
            fields: [
              XPStatusBarField(child: Text('Line 1, Column 1')),
              XPStatusBarField(child: Text('100%')),
            ],
          ),
          child: XPWindowBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, world!'),
                SizedBox(height: 16),
                XPFieldRow(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    XPButton(label: 'OK'),
                    XPButton(label: 'Cancel'),
                  ],
                ),
              ],
            ),
          ),
        ),
        size: const Size(500, 400),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(XPWindow),
      matchesGoldenFile('goldens/xp_window_golden.png'),
    );
  });

  testWidgets('XP Form Controls Golden Test', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 500));

    await tester.pumpWidget(
      _buildGoldenApp(
        XPGroupBox(
          label: 'Form Controls Showcase',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              XPFieldRow(
                children: [
                  XPButton(label: 'Click me'),
                  const XPButton(label: 'Disabled', enabled: false),
                ],
              ),
              const SizedBox(height: 12),
              XPFieldRowStacked(
                children: [
                  XPCheckbox(
                    value: false,
                    label: 'Unchecked',
                    onChanged: (v) {},
                  ),
                  XPCheckbox(
                    value: true,
                    label: 'Checked',
                    onChanged: (v) {},
                  ),
                  XPCheckbox(
                    value: true,
                    enabled: false,
                    label: 'Checked & Disabled',
                    onChanged: (v) {},
                  ),
                ],
              ),
              const SizedBox(height: 12),
              XPFieldRowStacked(
                children: [
                  XPRadioButton<int>(
                    value: 1,
                    groupValue: 1,
                    label: 'Selected Radio',
                    onChanged: (v) {},
                  ),
                  XPRadioButton<int>(
                    value: 2,
                    groupValue: 1,
                    label: 'Unselected Radio',
                    onChanged: (v) {},
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const XPTextField(placeholder: 'Text input field...'),
              const SizedBox(height: 12),
              const XPProgressBar(value: 0.65),
            ],
          ),
        ),
        size: const Size(500, 500),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(XPGroupBox),
      matchesGoldenFile('goldens/xp_form_controls_golden.png'),
    );
  });
}
