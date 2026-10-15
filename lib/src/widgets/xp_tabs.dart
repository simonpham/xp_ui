import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../painters/xp_painters.dart';
import '../theme/xp_theme.dart';

/// Single tab item definition for [XPTabs].
class XPTab {
  /// Custom widget to use as the tab header title.
  final Widget? titleWidget;

  /// String title for the tab header if [titleWidget] is not provided.
  final String? label;

  /// The body content to display when this tab is active.
  final Widget child;

  /// Creates an [XPTab].
  const XPTab({
    this.titleWidget,
    this.label,
    required this.child,
  });
}

/// Authentic Windows XP Tabbed Container widget matching XP.css.
///
/// Selected tabs rise 2px higher (26px vs 23px), have top orange border #E68B2C,
/// 2px warm yellow inset glow #FFC73C, and seamless tabpanel overlap.
class XPTabs extends StatelessWidget {
  /// The list of tabs to render.
  final List<XPTab> tabs;

  /// Index of the currently active tab.
  final int selectedIndex;

  /// Callback invoked when a tab header is tapped or selected via arrow keys.
  final ValueChanged<int> onTabSelected;

  /// Whether the tab headers should expand to fill the full container width.
  final bool justified;

  /// Creates an [XPTabs] container.
  const XPTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.justified = false,
  });

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) return const SizedBox.shrink();

    final safeIndex = selectedIndex.clamp(0, tabs.length - 1);

    return Focus(
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.arrowRight ||
            key == LogicalKeyboardKey.arrowDown) {
          if (safeIndex < tabs.length - 1) {
            onTabSelected(safeIndex + 1);
            return KeyEventResult.handled;
          }
        } else if (key == LogicalKeyboardKey.arrowLeft ||
            key == LogicalKeyboardKey.arrowUp) {
          if (safeIndex > 0) {
            onTabSelected(safeIndex - 1);
            return KeyEventResult.handled;
          }
        } else if (key == LogicalKeyboardKey.home) {
          onTabSelected(0);
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.end) {
          onTabSelected(tabs.length - 1);
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tab header row — 26px high
          // menu[role="tablist"] { margin: 0 0 -2px 0; padding-left: 3px; }
          SizedBox(
            height: 26,
            child: Padding(
              padding: const EdgeInsets.only(left: 3.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(tabs.length, (index) {
                  final isSelected = index == safeIndex;
                  final tab = tabs[index];
                  final button = _XPTabButton(
                    tab: tab,
                    isSelected: isSelected,
                    onTap: () => onTabSelected(index),
                  );

                  if (justified) {
                    return Expanded(child: button);
                  } else {
                    return button;
                  }
                }),
              ),
            ),
          ),
          // Tab panel body
          XPTabPanel(child: tabs[safeIndex].child),
        ],
      ),
    );
  }
}

class _XPTabButton extends StatefulWidget {
  final XPTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _XPTabButton({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_XPTabButton> createState() => _XPTabButtonState();
}

class _XPTabButtonState extends State<_XPTabButton> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    Widget titleChild;
    if (widget.tab.titleWidget != null) {
      titleChild = widget.tab.titleWidget!;
    } else {
      titleChild = Text(
        widget.tab.label ?? '',
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Arial',
          color: widget.isSelected
              ? const Color(0xFF000000)
              : const Color(0xFF222222),
          fontWeight: widget.isSelected ? FontWeight.normal : FontWeight.normal,
        ),
      );
    }

    final isSelected = widget.isSelected;
    final isHighlighted = isSelected || _isHovered;

    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            height: isSelected ? 26 : 23,
            margin: const EdgeInsets.only(right: 2),
            child: CustomPaint(
              foregroundPainter: _XPTabBorderPainter(
                isSelected: isSelected,
                isHighlighted: isHighlighted,
                isFocused: _isFocused,
              ),
              child: Container(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 2),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3.0),
                    topRight: Radius.circular(3.0),
                  ),
                  color: isSelected ? const Color(0xFFFCFCFE) : null,
                  gradient: !isSelected
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFFFAFAF9),
                            Color(0xFFF0F0EA),
                            Color(0xFFECEBE5),
                          ],
                          stops: [0.0, 0.26, 0.95, 1.0],
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: titleChild,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter that draws authentic XP tab borders & 2px top yellow glow.
class _XPTabBorderPainter extends CustomPainter {
  final bool isSelected;
  final bool isHighlighted;
  final bool isFocused;

  const _XPTabBorderPainter({
    required this.isSelected,
    required this.isHighlighted,
    required this.isFocused,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final topPaint = Paint()
      ..color =
          isHighlighted ? const Color(0xFFE68B2C) : const Color(0xFF91A7B4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final sidePaint = Paint()
      ..color = isSelected ? const Color(0xFF919B9C) : const Color(0xFF91A7B4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Top 2px yellow glow for hover / selected tab
    if (isHighlighted) {
      canvas.drawRect(
        Rect.fromLTWH(1, 1, size.width - 2, 2),
        Paint()..color = const Color(0xFFFFC73C),
      );
    }

    // Top border line
    canvas.drawLine(
        const Offset(1, 0.5), Offset(size.width - 1, 0.5), topPaint);
    // Left border line
    canvas.drawLine(const Offset(0.5, 1), Offset(0.5, size.height), sidePaint);
    // Right border line
    canvas.drawLine(Offset(size.width - 0.5, 1),
        Offset(size.width - 0.5, size.height), sidePaint);

    // Bottom border line (drawn ONLY for unselected tabs)
    if (!isSelected) {
      canvas.drawLine(Offset(0, size.height - 0.5),
          Offset(size.width, size.height - 0.5), sidePaint);
    }

    // Focused dotted outline (outline: 1px dotted #222; outline-offset: -4px)
    if (isFocused) {
      const XPDottedBorderPainter(color: Color(0xFF222222), inset: 4.0)
          .paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant _XPTabBorderPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected ||
        oldDelegate.isHighlighted != isHighlighted ||
        oldDelegate.isFocused != isFocused;
  }
}

/// Panel container for tab content.
///
/// Matches XP.css `[role=tabpanel]` with subtle gradient and inset shadows.
class XPTabPanel extends StatelessWidget {
  /// Content to display inside the tab panel.
  final Widget child;

  /// Padding around the tab panel content.
  final EdgeInsetsGeometry padding;

  /// Creates an [XPTabPanel].
  const XPTabPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14.0),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _XPTabPanelPainter(),
      child: Container(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _XPTabPanelPainter extends CustomPainter {
  const _XPTabPanelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Outer drop shadow: 1px 2px 2px 0px rgba(208,206,191,0.75)
    final shadowPaint = Paint()..color = const Color(0xBFD0CEBF);
    canvas.drawRect(Rect.fromLTWH(1, 2, size.width, size.height), shadowPaint);

    // Fill background: linear-gradient(180deg, #fcfcfe 0%, #f4f3ee 100%)
    const bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFCFCFE), Color(0xFFF4F3EE)],
    );
    canvas.drawRect(rect, Paint()..shader = bgGradient.createShader(rect));

    // Inner highlight lines: inset 1px 1px #fcfcfe, inset -1px -1px #fcfcfe
    final innerPaint = Paint()
      ..color = const Color(0xFFFCFCFE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(rect.deflate(1.5), innerPaint);

    // Outer border: 1px solid #919b9c
    final borderPaint = Paint()
      ..color = XPColors.tabBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(rect.deflate(0.5), borderPaint);
  }

  @override
  bool shouldRepaint(covariant _XPTabPanelPainter oldDelegate) => false;
}
