import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xp_dart/xp_dart.dart';

Widget _buildTestApp(Widget child) {
  return WidgetsApp(
    color: XPColors.surface,
    onGenerateRoute: (settings) {
      return PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) {
          return XPSurface(child: child);
        },
      );
    },
  );
}

void main() {
  testWidgets('XPWindow renders title and children correctly', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        const XPWindow(
          titleText: 'My First Program',
          statusBar: XPStatusBar(
            fields: [
              XPStatusBarField(child: Text('Line 1, Column 1')),
              XPStatusBarField(child: Text('100%')),
            ],
          ),
          child: XPWindowBody(
            child: Text('Hello XP!'),
          ),
        ),
      ),
    );

    expect(find.text('My First Program'), findsOneWidget);
    expect(find.text('Hello XP!'), findsOneWidget);
    expect(find.text('Line 1, Column 1'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets(
      'XPWindow renders inside unbounded height containers (SingleChildScrollView)',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        SingleChildScrollView(
          child: Column(
            children: const [
              XPWindow(
                titleText: 'Unbounded Window',
                child: XPWindowBody(
                  child: Text('Content in scrollview'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Unbounded Window'), findsOneWidget);
    expect(find.text('Content in scrollview'), findsOneWidget);
  });

  testWidgets('XPButton responds to taps', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      _buildTestApp(
        XPButton(
          label: 'OK',
          onPressed: () => tapped = true,
        ),
      ),
    );

    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('OK'));
    expect(tapped, isTrue);
  });

  testWidgets('XPCheckbox toggles value', (tester) async {
    bool value = false;

    await tester.pumpWidget(
      _buildTestApp(
        StatefulBuilder(
          builder: (context, setState) {
            return XPCheckbox(
              value: value,
              label: 'Enable feature',
              onChanged: (val) => setState(() => value = val),
            );
          },
        ),
      ),
    );

    expect(find.text('Enable feature'), findsOneWidget);
    await tester.tap(find.text('Enable feature'));
    await tester.pump();
    expect(value, isTrue);
  });

  testWidgets('XPRadioButton selects value', (tester) async {
    int selected = 1;

    await tester.pumpWidget(
      _buildTestApp(
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                XPRadioButton<int>(
                  value: 1,
                  groupValue: selected,
                  label: 'Option 1',
                  onChanged: (val) => setState(() => selected = val!),
                ),
                XPRadioButton<int>(
                  value: 2,
                  groupValue: selected,
                  label: 'Option 2',
                  onChanged: (val) => setState(() => selected = val!),
                ),
              ],
            );
          },
        ),
      ),
    );

    expect(find.text('Option 1'), findsOneWidget);
    expect(find.text('Option 2'), findsOneWidget);

    await tester.tap(find.text('Option 2'));
    await tester.pump();
    expect(selected, 2);
  });

  testWidgets('XPTextField renders and accepts text', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      _buildTestApp(
        XPTextField(
          controller: controller,
          placeholder: 'Type here...',
        ),
      ),
    );

    await tester.enterText(find.byType(XPTextField), 'XP Rocks');
    expect(controller.text, 'XP Rocks');
  });

  testWidgets('XPTextArea renders and accepts multiline text', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      _buildTestApp(
        XPTextArea(
          controller: controller,
          placeholder: 'Multi-line input...',
        ),
      ),
    );

    await tester.enterText(find.byType(XPTextArea), 'Line 1\nLine 2');
    expect(controller.text, 'Line 1\nLine 2');
  });

  testWidgets('XPDropdown renders selected item', (tester) async {
    String selected = 'Item 1';

    await tester.pumpWidget(
      _buildTestApp(
        StatefulBuilder(
          builder: (context, setState) {
            return XPDropdown<String>(
              value: selected,
              items: const [
                XPDropdownItem(value: 'Item 1', label: 'Item 1'),
                XPDropdownItem(value: 'Item 2', label: 'Item 2'),
              ],
              onChanged: (val) => setState(() => selected = val!),
            );
          },
        ),
      ),
    );

    expect(find.text('Item 1'), findsOneWidget);
  });

  testWidgets('XPSlider renders and changes value', (tester) async {
    double value = 50.0;

    await tester.pumpWidget(
      _buildTestApp(
        StatefulBuilder(
          builder: (context, setState) {
            return XPSlider(
              value: value,
              min: 0.0,
              max: 100.0,
              onChanged: (val) => setState(() => value = val),
            );
          },
        ),
      ),
    );

    expect(find.byType(XPSlider), findsOneWidget);
  });

  testWidgets('XPProgressBar renders determinate and indeterminate',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        const Column(
          children: [
            XPProgressBar(value: 0.45),
            XPProgressBar(value: null), // Indeterminate
          ],
        ),
      ),
    );

    expect(find.byType(XPProgressBar), findsNWidgets(2));
  });

  testWidgets('XPGroupBox renders legend and children', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        const XPGroupBox(
          label: 'User Settings',
          child: Text('Inside GroupBox'),
        ),
      ),
    );

    expect(find.text('User Settings'), findsOneWidget);
    expect(find.text('Inside GroupBox'), findsOneWidget);
  });

  testWidgets('XPTabs switches tabs', (tester) async {
    int currentTab = 0;

    await tester.pumpWidget(
      _buildTestApp(
        StatefulBuilder(
          builder: (context, setState) {
            return XPTabs(
              selectedIndex: currentTab,
              onTabSelected: (idx) => setState(() => currentTab = idx),
              tabs: const [
                XPTab(label: 'General', child: Text('General Settings')),
                XPTab(label: 'Advanced', child: Text('Advanced Settings')),
              ],
            );
          },
        ),
      ),
    );

    expect(find.text('General Settings'), findsOneWidget);
    expect(find.text('Advanced Settings'), findsNothing);

    await tester.tap(find.text('Advanced'));
    await tester.pump();

    expect(find.text('General Settings'), findsNothing);
    expect(find.text('Advanced Settings'), findsOneWidget);
  });

  testWidgets('XPTreeView renders items', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        const XPTreeView(
          items: [
            XPTreeItem(
              label: 'My Computer',
              children: [
                XPTreeItem(label: 'Local Disk (C:)'),
                XPTreeItem(label: 'CD Drive (D:)'),
              ],
            ),
          ],
        ),
      ),
    );

    expect(find.text('My Computer'), findsOneWidget);
  });

  testWidgets('XPScrollbar wraps scroll view', (tester) async {
    final controller = ScrollController();

    await tester.pumpWidget(
      _buildTestApp(
        SizedBox(
          height: 200,
          child: XPScrollbar(
            controller: controller,
            child: SingleChildScrollView(
              controller: controller,
              child: const SizedBox(height: 1000),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(XPScrollbar), findsOneWidget);
  });

  testWidgets('XPVerticalDivider and XPHorizontalDivider render correctly',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        const Column(
          children: [
            XPHorizontalDivider(),
            XPVerticalDivider(),
          ],
        ),
      ),
    );

    expect(find.byType(XPHorizontalDivider), findsOneWidget);
    expect(find.byType(XPVerticalDivider), findsOneWidget);
  });

  testWidgets('XPButton responds to keyboard Space and Enter keys',
      (tester) async {
    int tapCount = 0;

    await tester.pumpWidget(
      _buildTestApp(
        XPButton(
          autofocus: true,
          label: 'Submit',
          onPressed: () => tapCount++,
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(tapCount, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(tapCount, 2);
  });

  testWidgets('XPCheckbox responds to keyboard Space key', (tester) async {
    bool checked = false;

    await tester.pumpWidget(
      _buildTestApp(
        StatefulBuilder(
          builder: (context, setState) {
            return XPCheckbox(
              autofocus: true,
              value: checked,
              label: 'Check Me',
              onChanged: (val) => setState(() => checked = val),
            );
          },
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(checked, isTrue);
  });

  testWidgets('XPRadioButton responds to keyboard selection', (tester) async {
    int selected = 1;

    await tester.pumpWidget(
      _buildTestApp(
        StatefulBuilder(
          builder: (context, setState) {
            return XPRadioButton<int>(
              autofocus: true,
              value: 2,
              groupValue: selected,
              label: 'Radio Two',
              onChanged: (val) => setState(() => selected = val!),
            );
          },
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(selected, 2);
  });

  testWidgets('XPDropdown handles keyboard arrow keys and escape',
      (tester) async {
    String selected = 'Apple';

    await tester.pumpWidget(
      _buildTestApp(
        StatefulBuilder(
          builder: (context, setState) {
            return XPDropdown<String>(
              autofocus: true,
              value: selected,
              items: const [
                XPDropdownItem(value: 'Apple', label: 'Apple'),
                XPDropdownItem(value: 'Banana', label: 'Banana'),
                XPDropdownItem(value: 'Cherry', label: 'Cherry'),
              ],
              onChanged: (val) => setState(() => selected = val!),
            );
          },
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(selected, 'Banana');

    await tester.sendKeyEvent(LogicalKeyboardKey.space); // open dropdown
    await tester.pump();
    expect(find.text('Cherry'), findsWidgets);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape); // close dropdown
    await tester.pump();
  });
}
