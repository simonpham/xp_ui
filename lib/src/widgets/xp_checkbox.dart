import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../painters/xp_painters.dart';
import '../svg/xp_svg_assets.dart';
import '../svg/xp_svg_image.dart';
import '../theme/xp_theme.dart';

/// A Windows XP styled Checkbox widget matching XP.css.
class XPCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool enabled;
  final bool autofocus;

  const XPCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  State<XPCheckbox> createState() => _XPCheckboxState();
}

class _XPCheckboxState extends State<XPCheckbox> {
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
    widget.onChanged!(!widget.value);
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
                painter: XPCheckboxPainter(
                  isHovered: _isHovered,
                  isPressed: _isPressed,
                  isDisabled: !_effectiveEnabled,
                ),
                child: SizedBox(
                  width: 13,
                  height: 13,
                  child: widget.value
                      ? XPSvgImage(
                          svgString: !_effectiveEnabled
                              ? XPSvgAssets.checkmarkDisabledSvg
                              : XPSvgAssets.checkmarkSvg,
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

