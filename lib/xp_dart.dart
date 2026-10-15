/// Authentic Windows XP (Luna Blue) widgets for Flutter.
///
/// A faithful port of [XP.css](https://github.com/botoxparty/XP.css), built
/// only on `package:flutter/widgets.dart` and custom painters, with no
/// dependency on `material.dart` or `cupertino.dart`.
///
/// ```dart
/// import 'package:flutter/widgets.dart';
/// import 'package:xp_dart/xp_dart.dart';
///
/// XPWindow(
///   titleText: 'My First Program',
///   child: XPWindowBody(
///     child: XPButton(label: 'OK', onPressed: () {}),
///   ),
/// )
/// ```
library;

// Theme & Colors
export 'src/theme/xp_theme.dart';

// SVG Assets & Rendering
export 'src/svg/xp_svg_assets.dart';
export 'src/svg/xp_svg_image.dart';

// Low-level Custom Painters
export 'src/painters/xp_painters.dart';

// Widgets
export 'src/widgets/xp_button.dart';
export 'src/widgets/xp_checkbox.dart';
export 'src/widgets/xp_divider.dart';
export 'src/widgets/xp_dropdown.dart';
export 'src/widgets/xp_group_box.dart';
export 'src/widgets/xp_progress_bar.dart';
export 'src/widgets/xp_radio.dart';
export 'src/widgets/xp_scrollbar.dart';
export 'src/widgets/xp_slider.dart';
export 'src/widgets/xp_surface.dart';
export 'src/widgets/xp_tabs.dart';
export 'src/widgets/xp_text_field.dart';
export 'src/widgets/xp_tree_view.dart';
export 'src/widgets/xp_window.dart';
