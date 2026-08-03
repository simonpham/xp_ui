import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../painters/xp_painters.dart';
import '../svg/xp_svg_assets.dart';
import '../svg/xp_svg_image.dart';
import '../theme/xp_theme.dart';


/// Item for XPDropdown
class XPDropdownItem<T> {
  final T value;
  final String label;

  const XPDropdownItem({
    required this.value,
    required this.label,
  });
}

/// A Windows XP styled Dropdown select control matching XP.css.
class XPDropdown<T> extends StatefulWidget {
  final T? value;
  final List<XPDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final bool autofocus;

  const XPDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  State<XPDropdown<T>> createState() => _XPDropdownState<T>();
}

class _XPDropdownState<T> extends State<XPDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  late final FocusNode _focusNode;
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  bool get _effectiveEnabled => widget.enabled && widget.onChanged != null;

  void _toggleDropdown() {
    if (!_effectiveEnabled) return;
    _focusNode.requestFocus();
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_isOpen) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? const Size(150, 23);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeDropdown,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    border: Border.all(color: const Color(0xFF7F9DB9), width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.items.map((item) {
                        final isSelected = item.value == widget.value;
                        return _XPDropdownMenuItem<T>(
                          item: item,
                          isSelected: isSelected,
                          onTap: () {
                            _closeDropdown();
                            widget.onChanged?.call(item.value);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    if (!_isOpen) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  void _selectNext() {
    if (widget.items.isEmpty || !_effectiveEnabled) return;
    final currentIndex = widget.items.indexWhere((item) => item.value == widget.value);
    final nextIndex = (currentIndex + 1).clamp(0, widget.items.length - 1);
    widget.onChanged?.call(widget.items[nextIndex].value);
  }

  void _selectPrevious() {
    if (widget.items.isEmpty || !_effectiveEnabled) return;
    final currentIndex = widget.items.indexWhere((item) => item.value == widget.value);
    final prevIndex = (currentIndex - 1).clamp(0, widget.items.length - 1);
    widget.onChanged?.call(widget.items[prevIndex].value);
  }

  @override
  void dispose() {
    _closeDropdown();
    _focusNode.dispose();
    super.dispose();
  }

  String _getSvgString() {
    if (_isOpen) return XPSvgAssets.dropdownActiveSvg;
    if (_isHovered) return XPSvgAssets.dropdownHoverSvg;
    return XPSvgAssets.dropdownSvg;
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem = widget.items
        .where((item) => item.value == widget.value)
        .firstOrNull;

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: (node, event) {
        if (!_effectiveEnabled) return KeyEventResult.ignored;
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.space ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            _toggleDropdown();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            _closeDropdown();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _selectNext();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _selectPrevious();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: GestureDetector(
          onTap: _toggleDropdown,
          child: MouseRegion(
            cursor: _effectiveEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            onEnter: !_effectiveEnabled ? null : (_) => setState(() => _isHovered = true),
            onExit: !_effectiveEnabled ? null : (_) => setState(() => _isHovered = false),
            child: Container(
              height: 23,
              padding: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: !_effectiveEnabled ? const Color(0xFFECE9D8) : const Color(0xFFFFFFFF),
                border: Border.all(
                  color: !_effectiveEnabled ? const Color(0xFFC9C7BA) : const Color(0xFF7F9DB9),
                  width: 1,
                ),
                boxShadow: _isFocused && _effectiveEnabled
                    ? const [
                        BoxShadow(color: Color(0xFFFFFFFF), offset: Offset(2, 2)),
                        BoxShadow(color: Color(0xFFFFFFFF), offset: Offset(-2, -2)),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomPaint(
                      painter: _isFocused && _effectiveEnabled ? const XPDottedBorderPainter() : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Text(
                          selectedItem?.label ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 11,
                            color: !_effectiveEnabled ? XPColors.textDisabled : XPColors.text,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: 1.0),
                    child: SizedBox(
                      width: 15,
                      height: 17,
                      child: XPSvgImage(
                        svgString: _getSvgString(),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}




class _XPDropdownMenuItem<T> extends StatefulWidget {
  final XPDropdownItem<T> item;
  final bool isSelected;
  final VoidCallback onTap;

  const _XPDropdownMenuItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_XPDropdownMenuItem<T>> createState() => _XPDropdownMenuItemState<T>();
}

class _XPDropdownMenuItemState<T> extends State<_XPDropdownMenuItem<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = _isHovered || widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          color: highlighted ? const Color(0xFF316AC5) : const Color(0xFFFFFFFF),
          child: Text(
            widget.item.label,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 11,
              color: highlighted ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
            ),
          ),
        ),
      ),
    );
  }
}

