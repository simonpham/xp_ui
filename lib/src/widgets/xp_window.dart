import 'package:flutter/widgets.dart';
import '../painters/xp_painters.dart';
import '../svg/xp_svg_assets.dart';
import '../svg/xp_svg_image.dart';
import '../theme/xp_theme.dart';

/// A Windows XP styled Window container.
///
/// Features classic Luna Blue 6-tier nested border, gradient title bar,
/// window control buttons, window body, and status bar.
class XPWindow extends StatelessWidget {
  /// The main content child of the window.
  final Widget child;

  /// Title text displayed in the title bar.
  final String? titleText;

  /// Leading widget displayed before the title text (e.g. program icon).
  final Widget? titleLeading;

  /// Window control buttons to display on the top right (Minimize, Maximize, Close, Help).
  final List<XPWindowButtonType> buttons;

  /// Callback when the close button is pressed.
  final VoidCallback? onClose;

  /// Callback when the minimize button is pressed.
  final VoidCallback? onMinimize;

  /// Callback when the maximize or restore button is pressed.
  final VoidCallback? onMaximize;

  /// Callback when the help button is pressed.
  final VoidCallback? onHelp;

  /// Optional status bar widget pinned to the bottom of the window.
  final Widget? statusBar;

  /// Explicit width for the window.
  final double? width;

  /// Explicit height for the window.
  final double? height;

  /// Outer margin around the window frame.
  final EdgeInsetsGeometry? margin;

  /// Whether the window is currently active/focused (affects title bar gradient).
  final bool isFocused;

  /// Creates an [XPWindow].
  const XPWindow({
    super.key,
    required this.child,
    this.titleText,
    this.titleLeading,
    this.buttons = const [
      XPWindowButtonType.minimize,
      XPWindowButtonType.maximize,
      XPWindowButtonType.close,
    ],
    this.onClose,
    this.onMinimize,
    this.onMaximize,
    this.onHelp,
    this.statusBar,
    this.width,
    this.height,
    this.margin,
    this.isFocused = true,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: CustomPaint(
        painter: XPWindowPainter(),
        child: Padding(
          // .window { padding: 0 0 3px 0 } — title bar spans full width at top, body padded 3px
          padding: const EdgeInsets.only(bottom: 3.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final hasBoundedHeight = constraints.hasBoundedHeight;

              final titleBar = (titleText != null || titleLeading != null)
                  ? _XPWindowTitleBar(
                      titleText: titleText,
                      titleLeading: titleLeading,
                      buttons: buttons,
                      onClose: onClose,
                      onMinimize: onMinimize,
                      onMaximize: onMaximize,
                      onHelp: onHelp,
                      isFocused: isFocused,
                    )
                  : null;

              if (hasBoundedHeight) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (titleBar case final Widget tb) tb,
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: child,
                      ),
                    ),
                    if (statusBar case final Widget sb) sb,
                  ],
                );
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (titleBar case final Widget tb) tb,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: child,
                    ),
                    if (statusBar case final Widget sb) sb,
                  ],
                );
              }

            },
          ),
        ),
      ),
    );
  }
}

class _XPWindowTitleBar extends StatelessWidget {
  final String? titleText;
  final Widget? titleLeading;
  final List<XPWindowButtonType> buttons;
  final VoidCallback? onClose;
  final VoidCallback? onMinimize;
  final VoidCallback? onMaximize;
  final VoidCallback? onHelp;
  final bool isFocused;

  const _XPWindowTitleBar({
    this.titleText,
    this.titleLeading,
    required this.buttons,
    this.onClose,
    this.onMinimize,
    this.onMaximize,
    this.onHelp,
    required this.isFocused,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(7),
      ),
      child: CustomPaint(
        foregroundPainter: _XPTitleBarBorderPainter(),
        child: Container(
          height: 28,
          // .title-bar { padding: 3px 5px 3px 3px }
          padding: const EdgeInsets.only(top: 3, left: 3, right: 5, bottom: 3),
          decoration: BoxDecoration(


            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isFocused
                  ? const [
                      Color(0xFF0997FF), // 0%
                      Color(0xFF0053EE), // 8%
                      Color(0xFF0050EE), // 40%
                      Color(0xFF0066FF), // 88%
                      Color(0xFF0066FF), // 93%
                      Color(0xFF005BFF), // 95%
                      Color(0xFF003DD7), // 96% — rgba(0,61,215,1)
                      Color(0xFF003DD7), // 100%
                    ]
                  : const [
                      Color(0xFF7697DA),
                      Color(0xFF678BD7),
                      Color(0xFF567CD2),
                      Color(0xFF4C75D0),
                    ],
              stops: isFocused
                  ? const [0.0, 0.08, 0.40, 0.88, 0.93, 0.95, 0.96, 1.0]
                  : null,
            ),
          ),
          child: Row(
            children: [
              if (titleLeading != null) ...[
                titleLeading!,
                const SizedBox(width: 4),
              ],
              if (titleText != null)
                Expanded(
                  child: Padding(
                    // .title-bar-text { padding-left: 3px }
                    padding: const EdgeInsets.only(left: 3.0),
                    child: Text(
                      titleText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Trebuchet MS',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF),
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            color: Color(0xFF0F1089),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // .title-bar-controls button { margin-left: 2px }
              Row(
                mainAxisSize: MainAxisSize.min,
                children: buttons.map((btn) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: _XPWindowControlButton(
                      type: btn,
                      onPressed: () {
                        switch (btn) {
                          case XPWindowButtonType.close:
                            onClose?.call();
                            break;
                          case XPWindowButtonType.minimize:
                            onMinimize?.call();
                            break;
                          case XPWindowButtonType.maximize:
                          case XPWindowButtonType.restore:
                            onMaximize?.call();
                            break;
                          case XPWindowButtonType.help:
                            onHelp?.call();
                            break;
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _XPTitleBarBorderPainter extends CustomPainter {
  const _XPTitleBarBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final topLeftPaint = Paint()
      ..color = const Color(0xFF0831D9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final rightPaint = Paint()
      ..color = const Color(0xFF001EA0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(const Offset(0, 0.5), Offset(size.width, 0.5), topLeftPaint);
    canvas.drawLine(const Offset(0.5, 0), Offset(0.5, size.height), topLeftPaint);
    canvas.drawLine(Offset(size.width - 0.5, 0), Offset(size.width - 0.5, size.height), rightPaint);
  }

  @override
  bool shouldRepaint(covariant _XPTitleBarBorderPainter oldDelegate) => false;
}

class _XPWindowControlButton extends StatefulWidget {
  final XPWindowButtonType type;
  final VoidCallback? onPressed;

  const _XPWindowControlButton({
    required this.type,
    this.onPressed,
  });

  @override
  State<_XPWindowControlButton> createState() => _XPWindowControlButtonState();
}

class _XPWindowControlButtonState extends State<_XPWindowControlButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _enabled => widget.onPressed != null;

  String _getSvgString() {
    if (!_enabled) {
      switch (widget.type) {
        case XPWindowButtonType.close:
          return XPSvgAssets.closeSvg;
        case XPWindowButtonType.minimize:
          return XPSvgAssets.minimizeSvg;
        case XPWindowButtonType.maximize:
          return XPSvgAssets.maximizeSvg;
        case XPWindowButtonType.restore:
          return XPSvgAssets.restoreSvg;
        case XPWindowButtonType.help:
          return XPSvgAssets.helpSvg;
      }
    }

    switch (widget.type) {
      case XPWindowButtonType.close:
        if (_isPressed && _isHovered) return XPSvgAssets.closeActiveSvg;
        if (_isHovered) return XPSvgAssets.closeHoverSvg;
        return XPSvgAssets.closeSvg;
      case XPWindowButtonType.minimize:
        if (_isPressed && _isHovered) return XPSvgAssets.minimizeActiveSvg;
        if (_isHovered) return XPSvgAssets.minimizeHoverSvg;
        return XPSvgAssets.minimizeSvg;
      case XPWindowButtonType.maximize:
        if (_isPressed && _isHovered) return XPSvgAssets.maximizeActiveSvg;
        if (_isHovered) return XPSvgAssets.maximizeHoverSvg;
        return XPSvgAssets.maximizeSvg;
      case XPWindowButtonType.restore:
        if (_isPressed && _isHovered) return XPSvgAssets.restoreActiveSvg;
        if (_isHovered) return XPSvgAssets.restoreHoverSvg;
        return XPSvgAssets.restoreSvg;
      case XPWindowButtonType.help:
        if (_isPressed && _isHovered) return XPSvgAssets.helpActiveSvg;
        if (_isHovered) return XPSvgAssets.helpHoverSvg;
        return XPSvgAssets.helpSvg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: !_enabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: !_enabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: !_enabled ? null : () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: MouseRegion(
        cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: !_enabled ? null : (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() {
          _isHovered = false;
          _isPressed = false;
        }),
        // .title-bar-controls button { min-width: 21px; min-height: 21px }
        child: SizedBox(
          width: 21,
          height: 21,
          child: XPSvgImage(svgString: _getSvgString()),
        ),
      ),
    );
  }
}

/// Body container inside [XPWindow].
///
/// Matches XP.css `.window-body` with default 8px padding and surface color.
class XPWindowBody extends StatelessWidget {
  /// The content child.
  final Widget child;

  /// Padding around the window body content (defaults to 8.0).
  final EdgeInsetsGeometry padding;

  /// Creates an [XPWindowBody].
  const XPWindowBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      color: XPColors.surface,
      child: child,
    );
  }
}

/// Windows XP Status bar container matching XP.css.
///
/// Features classic inset top shadow and segmented fields.
class XPStatusBar extends StatelessWidget {
  /// List of [XPStatusBarField] widgets in the status bar.
  final List<XPStatusBarField> fields;

  /// Creates an [XPStatusBar].
  const XPStatusBar({
    super.key,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      child: CustomPaint(
        foregroundPainter: const _XPStatusBarInnerShadowPainter(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
          color: XPColors.surface,
          child: Row(
            children: List.generate(fields.length, (index) {
              final field = fields[index];
              return Expanded(
                child: XPStatusBarField(
                  isFirst: index == 0,
                  isLast: index == fields.length - 1,
                  child: field.child,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _XPStatusBarInnerShadowPainter extends CustomPainter {
  const _XPStatusBarInnerShadowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // box-shadow: inset 0px 1px 2px #808080
    final paint1 = Paint()
      ..color = const Color(0xFF808080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paint2 = Paint()
      ..color = const Color(0x66808080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(const Offset(0, 0.5), Offset(size.width, 0.5), paint1);
    canvas.drawLine(const Offset(0, 1.5), Offset(size.width, 1.5), paint2);
  }

  @override
  bool shouldRepaint(covariant _XPStatusBarInnerShadowPainter oldDelegate) => false;
}

/// Status bar field segment inside [XPStatusBar].
class XPStatusBarField extends StatelessWidget {
  /// The field content widget.
  final Widget child;

  /// Whether this is the first field in the bar (removes left border).
  final bool isFirst;

  /// Whether this is the last field in the bar (removes right border).
  final bool isLast;

  /// Creates an [XPStatusBarField].
  const XPStatusBarField({
    super.key,
    required this.child,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        border: Border(
          left: isFirst
              ? BorderSide.none
              : const BorderSide(color: Color(0xBFFFFFFF), width: 1),
          right: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xBFD0CEBF), width: 1),
        ),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'Arial',
          fontSize: 11,
          color: Color(0xFF000000),
        ),
        child: child,
      ),
    );
  }
}


