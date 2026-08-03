# xp_dart

A faithful Flutter port of [XP.css](https://github.com/botoxparty/XP.css), bringing authentic Windows XP themed UI components and styling to Flutter applications.

> **Zero Material / Cupertino Dependencies**: `xp_dart` is built exclusively using `package:flutter/widgets.dart` and low-level `CustomPainter` rendering. It does NOT import `material.dart` or `cupertino.dart`.

---

## Features

- 🪟 **XPWindow**: Authentic Luna Blue window container with 6-tier nested inset border, gradient title bar, window control buttons (Minimize, Maximize, Restore, Help, Close), and 3D status bar fields.
- 🔘 **XPButton**: Windows XP button with 3D gradient fill, hover orange glow, focus blue ring, active pressed state, and disabled state.
- ☑️ **XPCheckbox**: Custom green vector checkmark box with hover glow and disabled support.
- ⭕ **XPRadioButton**: Custom round radio button with green dot center, hover glow, and group selection.
- 📝 **XPTextField & XPTextArea**: Single-line text input and multi-line text area with XP blue selection highlight.
- 🔽 **XPDropdown**: Select / dropdown control with popup overlay menu.
- 🎚️ **XPSlider**: Horizontal and vertical slider / range controls with arrow pointer or box indicators.
- 📦 **XPGroupBox**: Fieldset with legendary Windows XP blue legend title breaking top border.
- 📑 **XPTabs & XPTabPanel**: Tabbed container with orange hover top line, yellow glow, and seamless panel integration.
- 🌳 **XPTreeView**: Hierarchical tree view with expand/collapse `+`/`-` toggle boxes and item selection.
- 🟩 **XPProgressBar**: Determinate and animated sliding indeterminate green progress bar.
- 🎨 **XPTheme & XPSurface**: Theme configuration and surface background container (`#ECE9D8`).

---

## Usage

```dart
import 'package:flutter/widgets.dart';
import 'package:xp_dart/xp_dart.dart';

void main() {
  runApp(
    WidgetsApp(
      color: XPColors.surface,
      onGenerateRoute: (settings) => PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const XPSurface(
          child: Center(
            child: XPWindow(
              width: 350,
              height: 220,
              titleText: 'My First Program',
              statusBar: XPStatusBar(
                fields: [
                  XPStatusBarField(child: Text('Status: Ready')),
                  XPStatusBarField(child: Text('100%')),
                ],
              ),
              child: XPWindowBody(
                child: Column(
                  children: [
                    Text('Hello, world!'),
                    SizedBox(height: 16),
                    XPButton(
                      label: 'OK',
                      onPressed: null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
```

---

## Verification

`xp_dart` includes an automated test suite verifying that no `material.dart` or `cupertino.dart` imports exist anywhere in the library.

Run tests:
```bash
flutter test
```

Run static analysis:
```bash
flutter analyze
```
