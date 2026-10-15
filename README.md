# xp_dart

[![pub package](https://img.shields.io/pub/v/xp_dart.svg)](https://pub.dev/packages/xp_dart)
[![pub points](https://img.shields.io/pub/points/xp_dart)](https://pub.dev/packages/xp_dart/score)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/simonpham/xp_ui/blob/develop/LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.10-02569B.svg?logo=flutter)](https://flutter.dev)
[![No Material](https://img.shields.io/badge/material%20%2F%20cupertino-none-success.svg)](#zero-material-zero-cupertino)

Authentic **Windows XP (Luna Blue)** widgets for Flutter. A faithful port of
[XP.css](https://github.com/botoxparty/XP.css), drawn with custom painters and
the original pixel-art icons, with **zero `material.dart` or
`cupertino.dart` dependencies**.

<p align="center">
  <img src="https://raw.githubusercontent.com/simonpham/xp_ui/develop/doc/screenshots/demo.gif" width="600" alt="Animated demo of xp_dart widgets: buttons, checkboxes, radio buttons, a progress bar, tabs, a dropdown and a slider inside a Windows XP window">
</p>

## Features

- 🪟 **Windows** with the Luna title bar gradient, 6-tier frame, minimize / maximize / restore / help / close buttons and a segmented status bar.
- 🔘 **Form controls**: push buttons, checkboxes, radio buttons, text fields, text areas, dropdowns and sliders, with hover, pressed, focused and disabled states.
- 🗂️ **Containers**: tabs, group boxes (fieldsets), tree views, XP scrollbars and 3D dividers.
- 🟩 **Progress bars**, determinate and the classic sliding indeterminate animation.
- ⌨️ **Keyboard support**: Space / Enter to activate, arrow keys for tabs, dropdowns and sliders, dotted focus rectangles.
- 🪶 **Lightweight**: built only on `package:flutter/widgets.dart`. Use it with `WidgetsApp`, or alongside any other design system.
- 🧪 **Tested**: widget tests, golden tests, and a test that fails the build if `material.dart` or `cupertino.dart` is ever imported.

## Screenshots

| Window & dialogs | Form controls | Explorer |
|:---:|:---:|:---:|
| <img src="https://raw.githubusercontent.com/simonpham/xp_ui/develop/doc/screenshots/window.png" width="280" alt="Mouse Properties dialog with tabs, group boxes, checkbox, slider and buttons, next to an inactive Copying window with a progress bar"> | <img src="https://raw.githubusercontent.com/simonpham/xp_ui/develop/doc/screenshots/controls.png" width="280" alt="Gallery of buttons, checkboxes, radio buttons, progress bars, text fields, dropdown and sliders"> | <img src="https://raw.githubusercontent.com/simonpham/xp_ui/develop/doc/screenshots/explorer.png" width="280" alt="My Computer window with a tree view, a scrolling file list and a status bar"> |

## Installation

```bash
flutter pub add xp_dart
```

or add it to your `pubspec.yaml`:

```yaml
dependencies:
  xp_dart: ^0.1.0
```

## Quick start

```dart
import 'package:flutter/widgets.dart';
import 'package:xp_dart/xp_dart.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  XPSvgImage.preloadAll(); // Optional: compile the icons up front.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Windows XP App',
      color: XPColors.surface,
      debugShowCheckedModeBanner: false,
      pageRouteBuilder: <T>(settings, builder) =>
          PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) =>
                builder(context),
          ),
      home: XPSurface(
        child: Center(
          child: XPWindow(
            width: 320,
            titleText: 'My First Program',
            onClose: () {},
            statusBar: const XPStatusBar(
              fields: [
                XPStatusBarField(child: Text('Ready')),
                XPStatusBarField(child: Text('100%')),
              ],
            ),
            child: XPWindowBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hello from Windows XP!'),
                  const SizedBox(height: 16),
                  XPFieldRow(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      XPButton(label: 'OK', onPressed: () {}),
                      XPButton(label: 'Cancel', onPressed: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## Widget gallery

| Widget | Description |
|---|---|
| `XPWindow`, `XPWindowBody` | Luna window frame, gradient title bar, control buttons (`XPWindowButtonType`), active / inactive state. |
| `XPStatusBar`, `XPStatusBarField` | Sunken status bar with segmented fields. |
| `XPButton` | 75×23 push button with hover glow, focus ring, pressed and disabled states. |
| `XPCheckbox` | Sunken checkbox with the green pixel-art checkmark. |
| `XPRadioButton<T>` | Radio button with the green dot, grouped through `groupValue`. |
| `XPTextField`, `XPTextArea` | Single and multi-line text input with placeholder and XP blue selection. |
| `XPDropdown<T>`, `XPDropdownItem<T>` | Select box with a popup list and keyboard navigation. |
| `XPSlider` | Horizontal or vertical trackbar, continuous or stepped, arrow or box thumb. |
| `XPTabs`, `XPTab`, `XPTabPanel` | Tab strip with the orange hover line and a seamless panel. |
| `XPGroupBox`, `XPFieldRow`, `XPFieldRowStacked` | Fieldset with a blue legend, plus row / column layout helpers with XP spacing. |
| `XPTreeView`, `XPTreeItem` | Hierarchical tree with dotted connectors and `+` / `-` toggles. |
| `XPProgressBar` | Green segmented progress bar; pass `value: null` for the indeterminate animation. |
| `XPScrollbar` | XP scrollbar with arrow buttons and gripper thumb, for any scrollable. |
| `XPHorizontalDivider`, `XPVerticalDivider` | 3D etched separators. |
| `XPSurface` | `#ECE9D8` background with the default XP text style. |
| `XPSvgImage`, `XPSvgAssets` | Cached renderer and raw SVG markup for the XP icons. |
| `XPButtonPainter`, `XPWindowPainter`, … | The low-level `CustomPainter`s, for building your own controls. |

### Examples

**Checkbox and radio buttons**

```dart
XPCheckbox(
  value: _showHidden,
  label: 'Show hidden files',
  onChanged: (v) => setState(() => _showHidden = v),
),
XPRadioButton<String>(
  value: 'details',
  groupValue: _view,
  label: 'Details',
  onChanged: (v) => setState(() => _view = v!),
),
```

**Tabs inside a group box**

```dart
XPTabs(
  selectedIndex: _tab,
  onTabSelected: (i) => setState(() => _tab = i),
  tabs: const [
    XPTab(label: 'General', child: Text('General settings')),
    XPTab(label: 'Advanced', child: Text('Advanced settings')),
  ],
)
```

**Dropdown, slider and progress bar**

```dart
XPDropdown<String>(
  value: _scheme,
  items: const [
    XPDropdownItem(value: 'blue', label: 'Luna Blue'),
    XPDropdownItem(value: 'olive', label: 'Luna Olive'),
  ],
  onChanged: (v) => setState(() => _scheme = v!),
),
XPSlider(value: _volume, divisions: 10, onChanged: (v) => setState(() => _volume = v)),
const XPProgressBar(value: 0.6),
const XPProgressBar(), // indeterminate
```

**Tree view with a scrollbar**

```dart
XPTreeView(
  height: 200,
  selectedItem: _selected,
  onItemTap: (item) => setState(() => _selected = item),
  items: const [
    XPTreeItem(
      label: 'My Computer',
      isExpanded: true,
      children: [XPTreeItem(label: 'Local Disk (C:)'), XPTreeItem(label: 'CD Drive (D:)')],
    ),
  ],
)

XPScrollbar(
  // The bar is drawn over the right edge, so leave 17px for it.
  child: ListView.builder(
    padding: const EdgeInsets.only(right: 17),
    itemCount: 1000,
    itemBuilder: (context, i) => Text('Item $i'),
  ),
)
```

The [example app](https://github.com/simonpham/xp_ui/tree/develop/example) ports the whole XP.css documentation page and shows every widget in context.

## Theming

The Luna Blue palette is exposed as `const` tokens on `XPColors`, so you can
match your own widgets to the look:

```dart
Container(color: XPColors.surface, child: ...);
Text('Legend', style: TextStyle(color: XPColors.legendColor));
```

`XPTheme` provides an `XPThemeData` (surface color, dialog blue, input border,
default text style and window title style) to the subtree. `XPSurface` uses
it for its background and default text style:

```dart
XPTheme(
  data: const XPThemeData().copyWith(
    textStyle: const TextStyle(fontFamily: 'Tahoma', fontSize: 11),
  ),
  child: const XPSurface(child: MyDesktop()),
)
```

### Fonts

Like XP.css, the controls ask for `Arial` (11px) and the window title for
`Trebuchet MS` (13px bold). These are not bundled. If they are missing on a
target platform (e.g. Linux, Android, web), Flutter falls back to the default
font. For a pixel-faithful result, bundle a compatible font in your app under
those family names:

```yaml
flutter:
  fonts:
    - family: Arial
      fonts:
        - asset: fonts/LiberationSans-Regular.ttf
        - asset: fonts/LiberationSans-Bold.ttf
          weight: 700
```

## Zero Material, zero Cupertino

`xp_dart` imports nothing but `package:flutter/widgets.dart`,
`package:flutter/services.dart`, `package:flutter/foundation.dart` and
[`jovial_svg`](https://pub.dev/packages/jovial_svg) for the icons. A test in
`test/no_material_or_cupertino_test.dart` keeps it that way. Your app can
still use Material or Cupertino if you want to; the XP widgets simply do not
need them.

## Performance

- Icons are embedded SVG strings compiled once by `jovial_svg` and cached. Call `XPSvgImage.preloadAll()` at startup to avoid compiling them on the first frame.
- Painters use `const` constructors and precise `shouldRepaint` checks.
- Controls only rebuild on real visual state changes (hover, press, focus).

## Contributing

Issues and pull requests are welcome at
[github.com/simonpham/xp_ui](https://github.com/simonpham/xp_ui/issues).

```bash
flutter analyze
flutter test
```

Golden images live in `test/goldens/`; regenerate them with
`flutter test --update-goldens` when a visual change is intended. The README
screenshots and GIF are rendered offscreen from the real widgets by
`tool/screenshots/capture_test.dart` (see the instructions at the top of that
file).

## Credits

Visual design, measurements and icons come from
[XP.css](https://github.com/botoxparty/XP.css) by Adam Hammad and Jordan
Scales (MIT). Windows XP is a trademark of Microsoft Corporation; this project
is not affiliated with or endorsed by Microsoft.

## License

MIT. See [LICENSE](https://github.com/simonpham/xp_ui/blob/develop/LICENSE).
