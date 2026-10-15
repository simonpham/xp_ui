import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../theme/xp_theme.dart';

/// Minimal TextSelectionControls for XPTextField using only package:flutter/widgets.dart.
class XPTextSelectionControls extends TextSelectionControls {
  /// Creates an [XPTextSelectionControls].
  XPTextSelectionControls();

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

/// Global shared selection controls instance for Windows XP text fields.
final TextSelectionControls xpTextSelectionControls = XPTextSelectionControls();

/// Authentic Windows XP single-line Text Input widget.
///
/// Features classic XP inset border (#7F9DB9) and white background.
class XPTextField extends StatefulWidget {
  /// Controller for editing text. If omitted, an internal controller is created.
  final TextEditingController? controller;

  /// Callback invoked when text changes.
  final ValueChanged<String>? onChanged;

  /// Callback invoked when user submits editing (e.g. presses enter).
  final ValueChanged<String>? onSubmitted;

  /// Whether to obscure text for password fields.
  final bool obscureText;

  /// Whether the input field is enabled.
  final bool enabled;

  /// Whether the input field should automatically focus when mounted.
  final bool autofocus;

  /// Placeholder hint text displayed when input is empty.
  final String? placeholder;

  /// Explicit width for the text field.
  final double? width;

  /// Creates an [XPTextField].
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
  late TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _wasEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _wasEmpty = _controller.text.isEmpty;
    _controller.addListener(_handleControllerChange);
    _focusNode = FocusNode(canRequestFocus: widget.enabled);
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  void _handleControllerChange() {
    final nowEmpty = _controller.text.isEmpty;
    if (_wasEmpty != nowEmpty) {
      _wasEmpty = nowEmpty;
      if (mounted) setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant XPTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_handleControllerChange);
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ?? TextEditingController();
      _wasEmpty = _controller.text.isEmpty;
      _controller.addListener(_handleControllerChange);
    }
    if (widget.enabled != oldWidget.enabled) {
      _focusNode.canRequestFocus = widget.enabled;
      if (!widget.enabled) _focusNode.unfocus();
    }
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
      color: widget.enabled ? const Color(0xFF000000) : XPColors.textDisabled,
    );

    return Container(
      width: widget.width,
      height: 23,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: widget.enabled ? XPColors.buttonHighlight : XPColors.buttonFace,
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
            readOnly: !widget.enabled,
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
  /// Controller for editing text. If omitted, an internal controller is created.
  final TextEditingController? controller;

  /// Callback invoked when text changes.
  final ValueChanged<String>? onChanged;

  /// Whether the text area is enabled.
  final bool enabled;

  /// Whether the text area should automatically focus when mounted.
  final bool autofocus;

  /// Placeholder hint text displayed when input is empty.
  final String? placeholder;

  /// Explicit width for the text area.
  final double? width;

  /// Explicit height for the text area (defaults to 80.0).
  final double? height;

  /// Maximum number of lines.
  final int? maxLines;

  /// Creates an [XPTextArea].
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
  late TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _wasEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _wasEmpty = _controller.text.isEmpty;
    _controller.addListener(_handleControllerChange);
    _focusNode = FocusNode(canRequestFocus: widget.enabled);
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  void _handleControllerChange() {
    final nowEmpty = _controller.text.isEmpty;
    if (_wasEmpty != nowEmpty) {
      _wasEmpty = nowEmpty;
      if (mounted) setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant XPTextArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_handleControllerChange);
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ?? TextEditingController();
      _wasEmpty = _controller.text.isEmpty;
      _controller.addListener(_handleControllerChange);
    }
    if (widget.enabled != oldWidget.enabled) {
      _focusNode.canRequestFocus = widget.enabled;
      if (!widget.enabled) _focusNode.unfocus();
    }
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
      color: widget.enabled ? const Color(0xFF000000) : XPColors.textDisabled,
    );

    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: widget.enabled ? XPColors.buttonHighlight : XPColors.buttonFace,
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
            readOnly: !widget.enabled,
            autofocus: widget.autofocus,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
