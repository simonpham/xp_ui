// Renders the README screenshots and the frames of the demo GIF offscreen,
// using the real widgets.
//
// Run from the repository root:
//
//   flutter test tool/screenshots/capture_test.dart
//   (cd tool/gif_encoder && dart pub get && \
//     dart run bin/encode_gif.dart ../../build/screenshot_frames \
//     ../../doc/screenshots/demo.gif)
//
// PNG screenshots are written to `doc/screenshots/`; GIF frames (plus a
// `frames.json` manifest with per-frame durations) are written to
// `build/screenshot_frames/`, then encoded by `tool/gif_encoder`.
//
// Text is rendered with Liberation Sans (metric-compatible with Arial). Set
// XP_FONT_DIR to point at a different directory containing
// LiberationSans-Regular.ttf and LiberationSans-Bold.ttf.

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xp_dart/xp_dart.dart';

const _screenshotDir = 'doc/screenshots';
const _framesDir = 'build/screenshot_frames';

final _boundaryKey = GlobalKey();
final _cursor = ValueNotifier<Offset?>(null);

Future<void> _loadFonts() async {
  final dir = Platform.environment['XP_FONT_DIR'] ??
      '/usr/share/fonts/truetype/liberation';
  final regular = File('$dir/LiberationSans-Regular.ttf').readAsBytesSync();
  final bold = File('$dir/LiberationSans-Bold.ttf').readAsBytesSync();
  for (final family in ['Arial', 'Trebuchet MS', 'Roboto']) {
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(regular)))
      ..addFont(Future.value(ByteData.sublistView(bold)));
    await loader.load();
  }
}

/// Wraps [child] in a desktop background, a fake mouse cursor and the
/// [RepaintBoundary] that is captured.
Widget _stage(Widget child) {
  return RepaintBoundary(
    key: _boundaryKey,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Positioned.fill(
            child: WidgetsApp(
              color: XPColors.surface,
              debugShowCheckedModeBanner: false,
              builder: (context, _) => Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (context) => CustomPaint(
                      painter: const _BlissPainter(),
                      child: DefaultTextStyle(
                        style: const XPThemeData().textStyle,
                        child: Center(child: child),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ValueListenableBuilder<Offset?>(
                valueListenable: _cursor,
                builder: (context, pos, _) => pos == null
                    ? const SizedBox.shrink()
                    : CustomPaint(painter: _CursorPainter(pos)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _capture(WidgetTester tester, String path,
    {double pixelRatio = 1}) async {
  await tester.runAsync(() async {
    final boundary = _boundaryKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File(path)..parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() async {
    await _loadFonts();
    XPSvgImage.preloadAll();
  });

  testWidgets('window.png', (tester) async {
    _setSize(tester, const Size(760, 520));
    await tester.pumpWidget(_stage(const _MousePropertiesScene()));
    await tester.pump(const Duration(milliseconds: 600));
    await _capture(tester, '$_screenshotDir/window.png', pixelRatio: 2);
  });

  testWidgets('controls.png', (tester) async {
    _setSize(tester, const Size(760, 560));
    await tester.pumpWidget(_stage(const _ControlsScene()));
    await tester.pump(const Duration(milliseconds: 700));
    await _capture(tester, '$_screenshotDir/controls.png', pixelRatio: 2);
  });

  testWidgets('explorer.png', (tester) async {
    _setSize(tester, const Size(760, 480));
    await tester.pumpWidget(_stage(const _ExplorerScene()));
    await tester.pump(const Duration(milliseconds: 300));
    await _capture(tester, '$_screenshotDir/explorer.png', pixelRatio: 2);
  });

  testWidgets('demo.gif frames', (tester) async {
    final dir = Directory(_framesDir);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);

    _setSize(tester, const Size(600, 340));
    final demoKey = GlobalKey<_DemoSceneState>();
    await tester.pumpWidget(_stage(_DemoScene(key: demoKey)));
    await tester.pump();

    final frames = <Map<String, Object>>[];
    Future<void> frame(int ms) async {
      await tester.pump();
      final name = 'frame_${frames.length.toString().padLeft(3, '0')}.png';
      await _capture(tester, '$_framesDir/$name', pixelRatio: 2);
      frames.add({'file': name, 'ms': ms});
    }

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    var pos = const Offset(540, 320);
    await mouse.addPointer(location: pos);
    _cursor.value = pos;

    Future<void> moveTo(Finder target, {int steps = 5}) async {
      final to = tester.getCenter(target);
      final from = pos;
      for (var i = 1; i <= steps; i++) {
        final t = Curves.easeInOut.transform(i / steps);
        pos = Offset.lerp(from, to, t)!;
        _cursor.value = pos;
        await mouse.moveTo(pos);
        await frame(40);
      }
    }

    Future<void> click({int holdMs = 120, int afterMs = 500}) async {
      await mouse.down(pos);
      await tester.pump(const Duration(milliseconds: 150));
      await frame(holdMs);
      await mouse.up();
      await tester.pump();
      await frame(afterMs);
    }

    await frame(900);

    // Hover and press the OK button.
    await moveTo(find.text('OK'));
    await frame(600);
    await click();

    // Toggle the checkboxes.
    await moveTo(find.text('Show hidden files'));
    await click(afterMs: 400);
    await moveTo(find.text('Hide file extensions'), steps: 3);
    await click(afterMs: 400);

    // Pick a radio button.
    await moveTo(find.text('Details'), steps: 4);
    await click(afterMs: 500);

    // Fill the progress bar.
    await moveTo(find.text('Copy'));
    await click(afterMs: 80);
    for (var i = 1; i <= 12; i++) {
      demoKey.currentState!.setProgress(i / 12);
      await frame(i == 12 ? 600 : 80);
    }

    // Switch tabs.
    await moveTo(find.text('Advanced'));
    await click(afterMs: 600);

    // Open the dropdown and choose an item.
    await moveTo(find.byType(XPDropdown<String>));
    await click(afterMs: 700);
    await moveTo(find.text('Luna Olive').last, steps: 3);
    await frame(400);
    await click(afterMs: 700);

    // Drag the slider.
    final slider = find.byType(XPSlider);
    final sliderRect = tester.getRect(slider);
    await moveTo(slider, steps: 4);
    await mouse.down(pos);
    for (var i = 1; i <= 6; i++) {
      pos = Offset(sliderRect.center.dx + i * 9, sliderRect.center.dy);
      _cursor.value = pos;
      await mouse.moveTo(pos);
      await frame(60);
    }
    await mouse.up();
    await frame(500);

    // Hover the close button.
    await moveTo(find.byType(XPSvgImage).at(2), steps: 6);
    await frame(1400);

    await mouse.removePointer();
    _cursor.value = null;

    File('$_framesDir/frames.json')
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(frames));
  });
}

// ---------------------------------------------------------------------------
// Scenes
// ---------------------------------------------------------------------------

class _MousePropertiesScene extends StatelessWidget {
  const _MousePropertiesScene();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 700,
      height: 460,
      child: Stack(
        children: [
          // Inactive window in the background.
          const Positioned(
            right: 0,
            top: 0,
            child: XPWindow(
              width: 330,
              titleText: 'Copying...',
              isFocused: false,
              buttons: [XPWindowButtonType.close],
              child: XPWindowBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('readme.txt'),
                    SizedBox(height: 4),
                    Text('From \'xp_dart\' to \'Desktop\''),
                    SizedBox(height: 10),
                    XPProgressBar(value: 0.62),
                    SizedBox(height: 6),
                    Text('3 Seconds Remaining'),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [XPButton(label: 'Cancel')],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: XPWindow(
              width: 400,
              titleText: 'Mouse Properties',
              buttons: const [
                XPWindowButtonType.help,
                XPWindowButtonType.close
              ],
              onClose: () {},
              child: XPWindowBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    XPTabs(
                      selectedIndex: 0,
                      onTabSelected: (_) {},
                      tabs: [
                        XPTab(
                          label: 'Buttons',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              XPGroupBox(
                                label: 'Button configuration',
                                child: XPCheckbox(
                                  value: false,
                                  label: 'Switch primary and secondary buttons',
                                  onChanged: (_) {},
                                ),
                              ),
                              XPGroupBox(
                                label: 'Double-click speed',
                                child: Row(
                                  children: [
                                    const Text('Slow'),
                                    const SizedBox(width: 6),
                                    XPSlider(
                                      value: 0.6,
                                      divisions: 10,
                                      width: 180,
                                      onChanged: (_) {},
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('Fast'),
                                  ],
                                ),
                              ),
                              XPGroupBox(
                                label: 'ClickLock',
                                margin: EdgeInsets.zero,
                                child: XPCheckbox(
                                  value: true,
                                  label: 'Turn on ClickLock',
                                  onChanged: (_) {},
                                ),
                              ),
                            ],
                          ),
                        ),
                        const XPTab(label: 'Pointers', child: SizedBox()),
                        const XPTab(label: 'Wheel', child: SizedBox()),
                        const XPTab(label: 'Hardware', child: SizedBox()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        XPButton(
                            label: 'OK', autofocus: true, onPressed: () {}),
                        const SizedBox(width: 6),
                        XPButton(label: 'Cancel', onPressed: () {}),
                        const SizedBox(width: 6),
                        const XPButton(label: 'Apply'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsScene extends StatelessWidget {
  const _ControlsScene();

  @override
  Widget build(BuildContext context) {
    void noop(Object? _) {}
    // Unbounded height lets the window shrink-wrap its content.
    return UnconstrainedBox(
        constrainedAxis: Axis.horizontal,
        child: XPWindow(
          width: 680,
          titleText: 'xp_dart Controls',
          onClose: () {},
          statusBar: const XPStatusBar(
            fields: [
              XPStatusBarField(child: Text('16 widgets')),
              XPStatusBarField(child: Text('Zero material / cupertino')),
              XPStatusBarField(child: Text('Luna Blue')),
            ],
          ),
          child: XPWindowBody(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      XPGroupBox(
                        label: 'Buttons',
                        child: XPFieldRow(
                          children: [
                            XPButton(label: 'Default', onPressed: () {}),
                            XPButton(
                                label: 'Focused',
                                autofocus: true,
                                onPressed: () {}),
                            const XPButton(label: 'Disabled'),
                          ],
                        ),
                      ),
                      XPGroupBox(
                        label: 'Checkboxes & radio buttons',
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: XPFieldRowStacked(
                                children: [
                                  XPCheckbox(
                                      value: true,
                                      label: 'Checked',
                                      onChanged: noop),
                                  XPCheckbox(
                                      value: false,
                                      label: 'Unchecked',
                                      onChanged: noop),
                                  const XPCheckbox(
                                      value: true,
                                      label: 'Disabled',
                                      onChanged: null),
                                ],
                              ),
                            ),
                            Expanded(
                              child: XPFieldRowStacked(
                                children: [
                                  XPRadioButton<int>(
                                      value: 1,
                                      groupValue: 1,
                                      label: 'Selected',
                                      onChanged: noop),
                                  XPRadioButton<int>(
                                      value: 2,
                                      groupValue: 1,
                                      label: 'Unselected',
                                      onChanged: noop),
                                  const XPRadioButton<int>(
                                      value: 1,
                                      groupValue: 1,
                                      label: 'Disabled',
                                      onChanged: null),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      XPGroupBox(
                        label: 'Progress',
                        margin: EdgeInsets.zero,
                        child: const XPFieldRowStacked(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            XPProgressBar(value: 0.7),
                            XPProgressBar(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      XPGroupBox(
                        label: 'Text input',
                        child: XPFieldRowStacked(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            XPTextField(
                              controller: TextEditingController(
                                  text: 'Hello, Windows XP'),
                            ),
                            const XPTextField(placeholder: 'Placeholder text'),
                            const XPTextArea(
                              height: 46,
                              placeholder: 'Multi-line text area',
                            ),
                          ],
                        ),
                      ),
                      XPGroupBox(
                        label: 'Dropdown & slider',
                        margin: EdgeInsets.zero,
                        child: XPFieldRowStacked(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            XPDropdown<String>(
                              value: 'Luna Blue',
                              items: const [
                                XPDropdownItem(
                                    value: 'Luna Blue', label: 'Luna Blue'),
                              ],
                              onChanged: noop,
                            ),
                            XPFieldRow(
                              children: [
                                const Text('Volume'),
                                XPSlider(
                                    value: 0.4, width: 120, onChanged: noop),
                                XPSlider(
                                  value: 0.7,
                                  width: 120,
                                  hasBoxIndicator: true,
                                  onChanged: noop,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class _ExplorerScene extends StatelessWidget {
  const _ExplorerScene();

  @override
  Widget build(BuildContext context) {
    const files = [
      'boot.ini',
      'Documents and Settings',
      'Program Files',
      'WINDOWS',
      'autoexec.bat',
      'config.sys',
      'hiberfil.sys',
      'IO.SYS',
      'MSDOS.SYS',
      'NTDETECT.COM',
      'ntldr',
      'pagefile.sys',
      'RECYCLER',
      'System Volume Information',
    ];
    return XPWindow(
      width: 640,
      height: 400,
      titleText: 'My Computer',
      onClose: () {},
      onMinimize: () {},
      onMaximize: () {},
      statusBar: const XPStatusBar(
        fields: [
          XPStatusBarField(child: Text('14 objects')),
          XPStatusBarField(child: Text('My Computer')),
        ],
      ),
      child: XPWindowBody(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 220,
              child: XPTreeView(
                selectedItem: const XPTreeItem(label: 'Local Disk (C:)'),
                items: const [
                  XPTreeItem(
                    label: 'Desktop',
                    isExpanded: true,
                    children: [
                      XPTreeItem(label: 'My Documents'),
                      XPTreeItem(
                        label: 'My Computer',
                        isExpanded: true,
                        children: [
                          XPTreeItem(label: '3½ Floppy (A:)'),
                          XPTreeItem(label: 'Local Disk (C:)'),
                          XPTreeItem(label: 'CD Drive (D:)'),
                          XPTreeItem(
                            label: 'Control Panel',
                            children: [XPTreeItem(label: 'Display')],
                          ),
                        ],
                      ),
                      XPTreeItem(
                        label: 'My Network Places',
                        children: [XPTreeItem(label: 'Entire Network')],
                      ),
                      XPTreeItem(label: 'Recycle Bin'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  border: Border.all(color: XPColors.inputBorder),
                ),
                child: XPScrollbar(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(right: 17),
                    itemCount: files.length * 3,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      child: Text(files[i % files.length]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoScene extends StatefulWidget {
  const _DemoScene({super.key});

  @override
  State<_DemoScene> createState() => _DemoSceneState();
}

class _DemoSceneState extends State<_DemoScene> {
  bool _hidden = false;
  bool _extensions = true;
  String _view = 'Icons';
  double _progress = 0;
  int _tab = 0;
  String _theme = 'Luna Blue';
  double _volume = 0.3;
  String _status = 'Ready';

  void setProgress(double v) => setState(() {
        _progress = v;
        _status = v >= 1 ? 'Copy complete' : 'Copying...';
      });

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
        constrainedAxis: Axis.horizontal,
        child: XPWindow(
          width: 540,
          titleText: 'xp_dart',
          onClose: () {},
          onMinimize: () {},
          onMaximize: () {},
          statusBar: XPStatusBar(
            fields: [
              XPStatusBarField(child: Text(_status)),
              XPStatusBarField(child: Text('${(_progress * 100).round()}%')),
            ],
          ),
          child: XPWindowBody(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      XPGroupBox(
                        label: 'Buttons',
                        child: XPFieldRow(
                          children: [
                            XPButton(
                              label: 'OK',
                              onPressed: () =>
                                  setState(() => _status = 'OK clicked'),
                            ),
                            XPButton(label: 'Cancel', onPressed: () {}),
                          ],
                        ),
                      ),
                      XPGroupBox(
                        label: 'Folder options',
                        margin: EdgeInsets.zero,
                        child: XPFieldRowStacked(
                          children: [
                            XPCheckbox(
                              value: _hidden,
                              label: 'Show hidden files',
                              onChanged: (v) => setState(() => _hidden = v),
                            ),
                            XPCheckbox(
                              value: _extensions,
                              label: 'Hide file extensions',
                              onChanged: (v) => setState(() => _extensions = v),
                            ),
                            const SizedBox(height: 2),
                            for (final view in ['Icons', 'Details'])
                              XPRadioButton<String>(
                                value: view,
                                groupValue: _view,
                                label: view,
                                onChanged: (v) => setState(() => _view = v!),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: XPTabs(
                    selectedIndex: _tab,
                    onTabSelected: (i) => setState(() => _tab = i),
                    tabs: [
                      XPTab(
                        label: 'General',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Copy files to the desktop:'),
                            const SizedBox(height: 8),
                            XPProgressBar(value: _progress),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: XPButton(
                                label: 'Copy',
                                onPressed: () => setProgress(0),
                              ),
                            ),
                            const SizedBox(height: 46),
                          ],
                        ),
                      ),
                      XPTab(
                        label: 'Advanced',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Color scheme:'),
                            const SizedBox(height: 4),
                            XPDropdown<String>(
                              value: _theme,
                              items: const [
                                XPDropdownItem(
                                    value: 'Luna Blue', label: 'Luna Blue'),
                                XPDropdownItem(
                                    value: 'Luna Olive', label: 'Luna Olive'),
                                XPDropdownItem(
                                    value: 'Luna Silver', label: 'Luna Silver'),
                              ],
                              onChanged: (v) => setState(() => _theme = v!),
                            ),
                            const SizedBox(height: 12),
                            const Text('Volume:'),
                            const SizedBox(height: 2),
                            XPSlider(
                              value: _volume,
                              width: 200,
                              onChanged: (v) => setState(() => _volume = v),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

// ---------------------------------------------------------------------------
// Decorations (only used for the screenshots, not part of the package)
// ---------------------------------------------------------------------------

/// A rough nod to the "Bliss" wallpaper: blue sky, soft clouds, green hill.
class _BlissPainter extends CustomPainter {
  const _BlissPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2F6FD8), Color(0xFF7FB2EE), Color(0xFFCFE3F7)],
          stops: [0.0, 0.45, 0.7],
        ).createShader(rect),
    );

    final cloud = Paint()
      ..color = const Color(0xCCFFFFFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final rnd = math.Random(7);
    for (var i = 0; i < 9; i++) {
      final c = Offset(
        rnd.nextDouble() * size.width,
        size.height * (0.08 + rnd.nextDouble() * 0.35),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: c,
          width: 90 + rnd.nextDouble() * 120,
          height: 22 + rnd.nextDouble() * 22,
        ),
        cloud,
      );
    }

    final hill = Path()
      ..moveTo(0, size.height * 0.66)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.42,
        size.width,
        size.height * 0.70,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      hill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF7CC242),
            Color(0xFF3F8F25),
            Color(0xFF2A6B1A)
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
          Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _BlissPainter oldDelegate) => false;
}

/// Classic arrow mouse pointer.
class _CursorPainter extends CustomPainter {
  const _CursorPainter(this.position);

  final Offset position;

  @override
  void paint(Canvas canvas, Size size) {
    const points = [
      Offset(0, 0),
      Offset(0, 17),
      Offset(4, 13),
      Offset(7, 19),
      Offset(10, 18),
      Offset(7, 12),
      Offset(12, 12),
    ];
    final path = Path()..addPolygon(points, true);
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CursorPainter oldDelegate) =>
      oldDelegate.position != position;
}
