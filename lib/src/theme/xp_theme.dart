import 'package:flutter/widgets.dart';

/// XP design system colors matching XP.css (Lunar Blue / Royale theme).
class XPColors {
  XPColors._();

  static const Color surface = Color(0xFFECE9D8);
  static const Color buttonHighlight = Color(0xFFFFFFFF);
  static const Color buttonFace = Color(0xFFDFDFDF);
  static const Color buttonShadow = Color(0xFF808080);
  static const Color windowFrame = Color(0xFF0A0A0A);
  static const Color dialogBlue = Color(0xFF2267CB);
  static const Color dialogBlueLight = Color(0xFF1084D0);
  static const Color linkBlue = Color(0xFF0000FF);
  static const Color inputBorder = Color(0xFF7F9DB9);
  static const Color radioBorder = Color(0xFF1D5281);
  static const Color radioBorderDisabled = Color(0xFFCAC8BB);
  static const Color legendColor = Color(0xFF0046D5);
  static const Color tabBorder = Color(0xFF919B9C);
  static const Color tabHoverTop = Color(0xFFE68B2C);
  static const Color tabHoverTopGlow = Color(0xFFFFC73C);
  static const Color progressBorder = Color(0xFF686868);
  static const Color buttonBorder = Color(0xFF003C74);
  static const Color text = Color(0xFF000000);
  static const Color textDisabledShadow = Color(0xFFFFFFFF);
  static const Color textDisabled = Color(0xFF808080);

  // XP Window border shades (6-tier inset border)
  static const Color windowBorder1 = Color(0xFF00138C);
  static const Color windowBorder2 = Color(0xFF0831D9);
  static const Color windowBorder3 = Color(0xFF001EA0);
  static const Color windowBorder4 = Color(0xFF166AEE);
  static const Color windowBorder5 = Color(0xFF003BDA);
  static const Color windowBorder6 = Color(0xFF0855DD);

  // Title bar gradient colors
  static const List<Color> titleBarGradient = [
    Color(0xFF0997FF),
    Color(0xFF0053EE),
    Color(0xFF0050EE),
    Color(0xFF0066FF),
    Color(0xFF0066FF),
    Color(0xFF005BFF),
    Color(0xFF003BD1),
    Color(0xFF003BD1),
  ];

  // Button normal gradient — rgba(255,255,255) 0%, rgba(236,235,229) 86%, rgba(216,208,196) 100%
  static const List<Color> buttonGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFECEBE5),
    Color(0xFFD8D0C4),
  ];
  static const List<double> buttonGradientStops = [0.0, 0.86, 1.0];

  // Button active gradient — #CDCAC3 0%, #E3E3DB 8%, #E5E5DE 94%, #F2F2F1 100%
  static const List<Color> buttonActiveGradient = [
    Color(0xFFCDCAC3),
    Color(0xFFE3E3DB),
    Color(0xFFE5E5DE),
    Color(0xFFF2F2F1),
  ];
  static const List<double> buttonActiveGradientStops = [0.0, 0.08, 0.94, 1.0];

  // Radio / Checkbox background gradient
  static const List<Color> controlBgGradient = [
    Color(0xFFDCDCD7),
    Color(0xFFFFFFFF),
  ];

  static const List<Color> controlBgActiveGradient = [
    Color(0xFFB0B0A7),
    Color(0xFFE3E1D2),
  ];

  // Tab gradient — matches _tabs.scss exactly
  // rgba(255,255,255) 0%, rgba(250,250,249) 26%, rgba(240,240,234) 95%, rgba(236,235,229) 100%
  static const List<Color> tabGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFFAFAF9),
    Color(0xFFF0F0EA),
    Color(0xFFECEBE5),
  ];
  static const List<double> tabGradientStops = [0.0, 0.26, 0.95, 1.0];

  // [role=tabpanel] box-shadow inner colours
  static const List<Color> tabPanelGradient = [
    Color(0xFFFCFCFE),
    Color(0xFFF4F3EE),
  ];

  // Progress bar green block gradient
  static const List<Color> progressBarGradient = [
    Color(0xFFACEDAD),
    Color(0xFF7BE47D),
    Color(0xFF4CDA50),
    Color(0xFF2ED330),
    Color(0xFF42D845),
    Color(0xFF76E275),
    Color(0xFF8FE791),
    Color(0xFFFFFFFF),
  ];
}

/// Theme configuration for xp_dart widgets.
class XPThemeData {
  /// Default surface background color (#ECE9D8).
  final Color surface;

  /// Primary dialog blue color (#2267CB).
  final Color dialogBlue;

  /// Border color for inputs (#7F9DB9).
  final Color inputBorder;

  /// Default text style for XP controls (11px, Arial).
  final TextStyle textStyle;

  /// Window title bar text style (13px, bold, Trebuchet MS with shadow).
  final TextStyle windowTitleStyle;

  /// Creates an [XPThemeData] instance.
  const XPThemeData({
    this.surface = XPColors.surface,
    this.dialogBlue = XPColors.dialogBlue,
    this.inputBorder = XPColors.inputBorder,
    this.textStyle = const TextStyle(
      fontSize: 11.0,
      color: Color(0xFF222222),
      fontFamily: 'Arial',
    ),
    this.windowTitleStyle = const TextStyle(
      fontSize: 13.0,
      fontWeight: FontWeight.bold,
      color: Color(0xFFFFFFFF),
      fontFamily: 'Trebuchet MS',
      shadows: [
        Shadow(
          offset: Offset(1, 1),
          color: Color(0xFF0F1089),
        ),
      ],
    ),
  });

  /// Creates a copy of this [XPThemeData] with the given fields replaced with new values.
  XPThemeData copyWith({
    Color? surface,
    Color? dialogBlue,
    Color? inputBorder,
    TextStyle? textStyle,
    TextStyle? windowTitleStyle,
  }) {
    return XPThemeData(
      surface: surface ?? this.surface,
      dialogBlue: dialogBlue ?? this.dialogBlue,
      inputBorder: inputBorder ?? this.inputBorder,
      textStyle: textStyle ?? this.textStyle,
      windowTitleStyle: windowTitleStyle ?? this.windowTitleStyle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XPThemeData &&
          runtimeType == other.runtimeType &&
          surface == other.surface &&
          dialogBlue == other.dialogBlue &&
          inputBorder == other.inputBorder &&
          textStyle == other.textStyle &&
          windowTitleStyle == other.windowTitleStyle;

  @override
  int get hashCode => Object.hash(
        surface,
        dialogBlue,
        inputBorder,
        textStyle,
        windowTitleStyle,
      );

  @override
  String toString() =>
      'XPThemeData(surface: $surface, dialogBlue: $dialogBlue)';
}

/// InheritedWidget providing [XPThemeData] down the widget tree.
class XPTheme extends InheritedWidget {
  /// The [XPThemeData] provided to descendants.
  final XPThemeData data;

  /// Creates an [XPTheme] widget.
  const XPTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Obtains the nearest [XPThemeData] from the given [context].
  ///
  /// Defaults to a standard [XPThemeData] if none is found.
  static XPThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<XPTheme>();
    return theme?.data ?? const XPThemeData();
  }

  @override
  bool updateShouldNotify(XPTheme oldWidget) => data != oldWidget.data;
}
