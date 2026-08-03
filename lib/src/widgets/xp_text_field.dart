import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../theme/xp_theme.dart';

/// Minimal TextSelectionControls for XPTextField using only package:flutter/widgets.dart.
class XPTextSelectionControls extends TextSelectionControls {
  @override
  Widget buildHandle(
      BuildContext context, TextSelectionHandleType type, double textLineHeight,
      [VoidCallback? onTap]) {
    return const SizedBox.shrink();
  }

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ValueListenable<ClipboardStatus>? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return const SizedBox.shrink();
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) =>
      Offset.zero;

  @override
  Size getHandleSize(double textLineHeight) => Size.zero;
}

final TextSelectionControls xpTextSelectionControls = XPTextSelectionControls();

/// Authentic Windows XP single-line Text Input widget.
class XPTextField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final String? placeholder;
  final double? width;

  const XPTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.placeholder,
    this.width,
  });

  @override
  State<XPTextField> createState() => _XPTextFieldState();
}

class _XPTextFieldState extends State<XPTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleControllerChange);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  void _handleControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 11,
      fontFamily: 'Arial',
      color: widget.enabled
          ? const Color(0xFF000000)
          : XPColors.textDisabled,
    );

    return Container(
      width: widget.width,
      height: 23,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: widget.enabled
            ? XPColors.buttonHighlight
            : XPColors.buttonFace,
        border: Border.all(
          color: widget.enabled
              ? XPColors.inputBorder
              : XPColors.radioBorderDisabled,
          width: 1.0,
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          if (widget.placeholder != null &&
              _controller.text.isEmpty &&
              !_isFocused)
            Text(
              widget.placeholder!,
              style: textStyle.copyWith(color: const Color(0xFF888888)),
            ),
          EditableText(
            controller: _controller,
            focusNode: _focusNode,
            style: textStyle,
            cursorColor: const Color(0xFF000000),
            backgroundCursorColor: const Color(0xFFCCCCCC),
            selectionColor: XPColors.dialogBlue,
            selectionControls: xpTextSelectionControls,
            obscureText: widget.obscureText,
            autofocus: widget.autofocus,
            maxLines: 1,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
          ),
        ],
      ),
    );
  }
}

/// Authentic Windows XP multi-line Text Area widget.
class XPTextArea extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autofocus;
  final String? placeholder;
  final double? width;
  final double? height;
  final int? maxLines;

  const XPTextArea({
    super.key,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.placeholder,
    this.width,
    this.height = 80.0,
    this.maxLines,
  });

  @override
  State<XPTextArea> createState() => _XPTextAreaState();
}

class _XPTextAreaState extends State<XPTextArea> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleControllerChange);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  void _handleControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 11,
      fontFamily: 'Arial',
      color: widget.enabled
          ? const Color(0xFF000000)
          : XPColors.textDisabled,
    );

    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: widget.enabled
            ? XPColors.buttonHighlight
            : XPColors.buttonFace,
        border: Border.all(
          color: widget.enabled
              ? XPColors.inputBorder
              : XPColors.radioBorderDisabled,
          width: 1.0,
        ),
      ),
      alignment: Alignment.topLeft,
      child: Stack(
        children: [
          if (widget.placeholder != null &&
              _controller.text.isEmpty &&
              !_isFocused)
            Text(
              widget.placeholder!,
              style: textStyle.copyWith(color: const Color(0xFF888888)),
            ),
          EditableText(
            controller: _controller,
            focusNode: _focusNode,
            style: textStyle,
            cursorColor: const Color(0xFF000000),
            backgroundCursorColor: const Color(0xFFCCCCCC),
            selectionColor: XPColors.dialogBlue,
            selectionControls: xpTextSelectionControls,
            autofocus: widget.autofocus,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}

