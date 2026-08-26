import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../painters/xp_painters.dart';
import '../svg/xp_svg_assets.dart';
import '../svg/xp_svg_image.dart';
import '../theme/xp_theme.dart';

/// A Windows XP styled Radio Button widget matching XP.css.
///
/// Displays a circular radio button with authentic 3D gradient, hover shadow,
/// and green dot indicator when selected.
class XPRadioButton<T> extends StatefulWidget {
  /// The value represented by this radio button.
  final T value;

  /// The currently selected value for the radio group.
  final T? groupValue;

  /// Callback invoked when this radio button is selected.
  final ValueChanged<T?>? onChanged;

  /// Optional text label displayed next to the radio button.
  final String? label;

  /// Whether the radio button is enabled and interactive.
  final bool enabled;

  /// Whether the radio button should automatically focus when mounted.
  final bool autofocus;

  /// Creates an [XPRadioButton].
  const XPRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.enabled = true,
    this.autofocus = false,
  });

  /// Whether this radio button is currently selected.
  bool get isSelected => value == groupValue;

  @override
  State<XPRadioButton<T>> createState() => _XPRadioButtonState<T>();
}


class _XPRadioButtonState<T> extends State<XPRadioButton<T>> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get _effectiveEnabled => widget.enabled && widget.onChanged != null;

  void _handleTap() {
    if (!_effectiveEnabled) return;
    _focusNode.requestFocus();
    widget.onChanged!(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: (node, event) {
        if (_effectiveEnabled &&
            event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          _handleTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTapDown: !_effectiveEnabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: !_effectiveEnabled ? null : (_) => setState(() => _isPressed = false),
        onTapCancel: !_effectiveEnabled ? null : () => setState(() => _isPressed = false),
        onTap: _handleTap,
        child: MouseRegion(
          cursor: _effectiveEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: !_effectiveEnabled ? null : (_) => setState(() => _isHovered = true),
          onExit: !_effectiveEnabled ? null : (_) => setState(() => _isHovered = false),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomPaint(
                painter: XPRadioPainter(
                  isHovered: _isHovered,
                  isPressed: _isPressed,
                  isDisabled: !_effectiveEnabled,
                ),
                child: SizedBox(
                  width: 13,
                  height: 13,
                  child: widget.isSelected
                      ? Center(
                          child: SizedBox(
                            width: 5,
                            height: 5,
                            child: XPSvgImage(
                              svgString: !_effectiveEnabled
                                  ? XPSvgAssets.radioDotDisabledSvg
                                  : XPSvgAssets.radioDotSvg,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              if (widget.label != null) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: CustomPaint(
                    painter: _isFocused ? const XPDottedBorderPainter() : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      child: Text(
                        widget.label!,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 11,
                          height: 16 / 11,
                          color: !_effectiveEnabled ? XPColors.textDisabled : XPColors.text,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

            ],
          ),
        ),
      ),
    );
  }
}

