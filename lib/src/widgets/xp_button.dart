import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../painters/xp_painters.dart';
import '../theme/xp_theme.dart';

/// Authentic Windows XP Button widget matching XP.css.
class XPButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? label;
  final double minWidth;
  final double minHeight;
  final EdgeInsetsGeometry padding;
  final bool enabled;
  final bool autofocus;

  const XPButton({
    super.key,
    this.onPressed,
    this.child,
    this.label,
    this.minWidth = 75.0,
    this.minHeight = 23.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  State<XPButton> createState() => _XPButtonState();
}

class _XPButtonState extends State<XPButton> {
  bool _isHovered = false;
  bool _isActive = false;
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

  bool get _effectiveEnabled => widget.enabled && widget.onPressed != null;

  void _handleTap() {
    if (_effectiveEnabled) {
      _focusNode.requestFocus();
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (widget.child != null) {
      content = widget.child!;
    } else if (widget.label != null) {
      // button { font-family: var(--sans-serif); font-size: 11px }
      content = Text(
        widget.label!,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Arial',
          color: _effectiveEnabled
              ? const Color(0xFF000000)
              : XPColors.textDisabled,
          shadows: !_effectiveEnabled
              ? const [
                  Shadow(
                    offset: Offset(1, 1),
                    color: XPColors.textDisabledShadow,
                  ),
                ]
              : null,
        ),
      );
    } else {
      content = const SizedBox.shrink();
    }

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
      child: MouseRegion(
        cursor: _effectiveEnabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) {
          if (_effectiveEnabled) setState(() => _isHovered = true);
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
            _isActive = false;
          });
        },
        child: GestureDetector(
          onTapDown: (_) {
            if (_effectiveEnabled) {
              _focusNode.requestFocus();
              setState(() => _isActive = true);
            }
          },
          onTapUp: (_) {
            if (_effectiveEnabled) setState(() => _isActive = false);
          },
          onTapCancel: () {
            if (_effectiveEnabled) setState(() => _isActive = false);
          },
          onTap: _handleTap,
          child: CustomPaint(
            painter: XPButtonPainter(
              isHovered: _isHovered,
              isActive: _isActive,
              isFocused: _isFocused,
              isDisabled: !_effectiveEnabled,
            ),
            child: Container(
              constraints: BoxConstraints(
                minWidth: widget.minWidth,
                minHeight: widget.minHeight,
              ),
              padding: widget.padding,
              alignment: Alignment.center,
              child: content,


            ),
          ),
        ),
      ),
    );
  }
}

