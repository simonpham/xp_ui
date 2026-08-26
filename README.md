# xp_dart

[![pub package](https://img.shields.io/badge/pub-0.0.1-blue.svg)](https://pub.dev/packages/xp_dart)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-02569B.svg?logo=flutter)](https://flutter.dev)

A faithful, high-performance Flutter port of [XP.css](https://github.com/botoxparty/XP.css), bringing authentic Windows XP (Luna Blue) themed UI components and styling to Flutter applications.

> **100% Independent from Material and Cupertino**: `xp_dart` is built exclusively on top of `package:flutter/widgets.dart` and low-level `CustomPainter` rendering. It does **not** import or depend on `package:flutter/material.dart` or `package:flutter/cupertino.dart`.

---

## Features & Components

| Component | Description |
|---|---|
| [**XPWindow**](file:///lib/src/widgets/xp_window.dart) | Authentic Luna Blue window with 6-tier nested inset border, gradient title bar, window control buttons (Minimize, Maximize, Restore, Help, Close), and 3D status bar fields. |
| [**XPButton**](file:///lib/src/widgets/xp_button.dart) | Windows XP button with 3D gradient fill, hover orange glow, focus blue ring, active pressed state, and disabled state. |
| [**XPCheckbox**](file:///lib/src/widgets/xp_checkbox.dart) | Sunken square checkbox with custom green vector checkmark, hover glow, and disabled support. |
| [**XPRadioButton**](file:///lib/src/widgets/xp_radio.dart) | Circular radio button with green dot center, hover glow, and mutually exclusive group selection. |
| [**XPTextField & XPTextArea**](file:///lib/src/widgets/xp_text_field.dart) | Single-line text input and multi-line text area with XP blue selection highlight and zero-overhead empty-state listeners. |
| [**XPDropdown**](file:///lib/src/widgets/xp_dropdown.dart) | Select dropdown control with popup overlay menu, keyboard navigation (Up, Down, Enter, Space, Escape), and highlighted item states. |
| [**XPSlider**](file:///lib/src/widgets/xp_slider.dart) | Horizontal and vertical slider / range controls with arrow pointer or box indicators, supporting keyboard stepping. |
| [**XPGroupBox**](file:///lib/src/widgets/xp_group_box.dart) | Fieldset with legendary Windows XP blue legend title breaking the top engraved border. |
| [**XPTabs & XPTabPanel**](file:///lib/src/widgets/xp_tabs.dart) | Tabbed container with orange hover top line, yellow glow, keyboard navigation, and seamless panel integration. |
| [**XPTreeView**](file:///lib/src/widgets/xp_tree_view.dart) | Hierarchical tree view with dotted connecting lines, expand/collapse `+`/`-` toggle boxes, and node selection. |
| [**XPProgressBar**](file:///lib/src/widgets/xp_progress_bar.dart) | Determinate and animated sliding indeterminate green segmented progress bar. |
| [**XPScrollbar**](file:///lib/src/widgets/xp_scrollbar.dart) | Scrollbar with 17px SVG arrow buttons, thumb gripper lines, and smooth scroll integration. |
| [**XPVerticalDivider & XPHorizontalDivider**](file:///lib/src/widgets/xp_divider.dart) | 3D beveled horizontal and vertical dividers. |
| [**XPTheme & XPSurface**](file:///lib/src/theme/xp_theme.dart) | Theme configuration, color tokens, and surface background container (`#ECE9D8`). |
| [**XPSvgImage & XPSvgAssets**](file:///lib/src/svg/xp_svg_image.dart) | High-performance compiled SVG asset renderer with static caching and optional preloading. |

---

## Getting Started

Add `xp_dart` to your `pubspec.yaml`:

```yaml
dependencies:
  xp_dart: ^0.0.1
```

Import `xp_dart` in your code:

```dart
import 'package:flutter/widgets.dart';
import 'package:xp_dart/xp_dart.dart';
```

---

## Quick Example

```dart
import 'package:flutter/widgets.dart';
import 'package:xp_dart/xp_dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Windows XP App',
      color: XPColors.surface,
      onGenerateRoute: (settings) => PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const XPSurface(
          child: Center(
            child: XPWindow(
              width: 380,
              titleText: 'My First Program',
              statusBar: XPStatusBar(
                fields: [
                  XPStatusBarField(child: Text('Status: Ready')),
                  XPStatusBarField(child: Text('100%')),
                ],
              ),
              child: XPWindowBody(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello from Windows XP in Flutter!'),
                    SizedBox(height: 16),
                    XPFieldRow(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        XPButton(
                          label: 'OK',
                          onPressed: () {},
                        ),
                        XPButton(
                          label: 'Cancel',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Performance Optimizations

- **Static Cache SVG Rendering**: Embedded vector assets are compiled with `jovial_svg` and cached in memory. Call `XPSvgImage.preloadAll()` at app start to ensure zero compilation latency on first render.
- **Low-overhead Custom Painters**: All painters utilize `const` constructors, static constant `LinearGradient`s, and avoid heap allocations during paint calls.
- **Smart Rebuilds**: Form controls, text fields, and group boxes minimize `setState` calls by caching measurements and only rebuilding when visual state transitions occur.

---

## Verification & Testing

`xp_dart` includes automated unit tests, widget tests, golden tests, and an import verifier confirming zero imports of `package:flutter/material.dart` and `package:flutter/cupertino.dart`.

Run tests:
```bash
flutter test
```

Run static analysis:
```bash
flutter analyze
```

---

## License

MIT License - see [LICENSE](file:///LICENSE) for details.

