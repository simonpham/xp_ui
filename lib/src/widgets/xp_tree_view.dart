import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../painters/xp_painters.dart';
import '../theme/xp_theme.dart';

/// Item node data structure for [XPTreeView].
class XPTreeItem {
  /// The label displayed for this node.
  final String label;

  /// Optional custom leading icon widget.
  final Widget? icon;

  /// Child nodes beneath this item.
  final List<XPTreeItem> children;

  /// Whether this tree node is currently expanded.
  final bool isExpanded;

  /// Optional unique identifier for this tree item.
  final Object? id;

  /// Creates an [XPTreeItem].
  const XPTreeItem({
    required this.label,
    this.icon,
    this.children = const [],
    this.isExpanded = false,
    this.id,
  });

  /// Creates a copy of this [XPTreeItem] with given fields replaced.
  XPTreeItem copyWith({
    String? label,
    Widget? icon,
    List<XPTreeItem>? children,
    bool? isExpanded,
    Object? id,
  }) {
    return XPTreeItem(
      label: label ?? this.label,
      icon: icon ?? this.icon,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XPTreeItem &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          isExpanded == other.isExpanded &&
          id == other.id;

  @override
  int get hashCode => Object.hash(label, isExpanded, id);

  @override
  String toString() =>
      'XPTreeItem(label: $label, isExpanded: $isExpanded, id: $id)';
}

/// Authentic Windows XP TreeView widget with optional dotted connecting lines.
class XPTreeView extends StatelessWidget {
  /// Root items in the hierarchical tree.
  final List<XPTreeItem> items;

  /// Currently selected tree node.
  final XPTreeItem? selectedItem;

  /// Callback invoked when a tree item is selected/tapped.
  final ValueChanged<XPTreeItem>? onItemTap;

  /// Callback invoked when an item is expanded or collapsed.
  final ValueChanged<XPTreeItem>? onItemToggle;

  /// Explicit width for the tree view container.
  final double? width;

  /// Explicit height for the tree view container.
  final double? height;

  /// Inner padding inside the tree view container.
  final EdgeInsetsGeometry padding;

  /// Whether to render Windows XP classic dotted hierarchy lines (defaults to true).
  final bool showLines;

  /// Creates an [XPTreeView].
  const XPTreeView({
    super.key,
    required this.items,
    this.selectedItem,
    this.onItemTap,
    this.onItemToggle,
    this.width,
    this.height,
    // ul.tree-view { padding: 2px 5px } per _treeview.scss
    this.padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    this.showLines = true,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent || items.isEmpty) {
          return KeyEventResult.ignored;
        }

        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.space ||
            key == LogicalKeyboardKey.enter) {
          if (selectedItem != null && onItemTap != null) {
            onItemTap!(selectedItem!);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: XPColors.buttonHighlight,
          border: Border.all(
            color: XPColors.inputBorder,
            width: 1.0,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isLast = idx == items.length - 1;
              return _XPTreeNodeTile(
                item: item,
                selectedItem: selectedItem,
                onItemTap: onItemTap,
                onItemToggle: onItemToggle,
                depth: 0,
                showLines: showLines,
                isLastChild: isLast,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _XPTreeNodeTile extends StatefulWidget {
  final XPTreeItem item;
  final XPTreeItem? selectedItem;
  final ValueChanged<XPTreeItem>? onItemTap;
  final ValueChanged<XPTreeItem>? onItemToggle;
  final int depth;
  final bool showLines;
  final bool isLastChild;

  const _XPTreeNodeTile({
    required this.item,
    required this.selectedItem,
    required this.onItemTap,
    required this.onItemToggle,
    required this.depth,
    required this.showLines,
    this.isLastChild = false,
  });

  @override
  State<_XPTreeNodeTile> createState() => _XPTreeNodeTileState();
}

class _XPTreeNodeTileState extends State<_XPTreeNodeTile> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.item.isExpanded;
  }

  @override
  void didUpdateWidget(covariant _XPTreeNodeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.isExpanded != oldWidget.item.isExpanded) {
      _expanded = widget.item.isExpanded;
    }
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    widget.onItemToggle?.call(widget.item.copyWith(isExpanded: _expanded));
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.item.children.isNotEmpty;
    final isSelected = widget.selectedItem == widget.item ||
        (widget.selectedItem?.id != null &&
            widget.selectedItem?.id == widget.item.id);

    return CustomPaint(
      foregroundPainter: widget.showLines && widget.depth > 0
          ? _XPTreeDottedConnectorPainter(
              depth: widget.depth,
              isLastChild: widget.isLastChild,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 18,
            margin: const EdgeInsets.only(top: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: (widget.depth * 16).toDouble()),
                if (hasChildren)
                  GestureDetector(
                    onTap: _toggle,
                    child: Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.only(right: 5),
                      child: CustomPaint(
                        painter: _XPTreeTogglePainter(isExpanded: _expanded),
                      ),
                    ),
                  )
                else if (widget.depth > 0)
                  const SizedBox(width: 4),
                if (widget.item.icon != null) ...[
                  widget.item.icon!,
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: GestureDetector(
                    onTap: () => widget.onItemTap?.call(widget.item),
                    child: CustomPaint(
                      painter: isSelected
                          ? const XPDottedBorderPainter(
                              color: Color(0xFFFFFFFF))
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        color: isSelected ? XPColors.dialogBlue : null,
                        child: Text(
                          widget.item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'Arial',
                            color: isSelected
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF000000),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasChildren && _expanded)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.item.children.asMap().entries.map((entry) {
                final idx = entry.key;
                final child = entry.value;
                final isLast = idx == widget.item.children.length - 1;
                return _XPTreeNodeTile(
                  item: child,
                  selectedItem: widget.selectedItem,
                  onItemTap: widget.onItemTap,
                  onItemToggle: widget.onItemToggle,
                  depth: widget.depth + 1,
                  showLines: widget.showLines,
                  isLastChild: isLast,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _XPTreeTogglePainter extends CustomPainter {
  final bool isExpanded;

  const _XPTreeTogglePainter({required this.isExpanded});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawRect(
      rect.deflate(0.5),
      Paint()
        ..color = const Color(0xFF808080)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final linePaint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 1.0;

    // Horizontal line
    canvas.drawLine(const Offset(2, 4.5), const Offset(7, 4.5), linePaint);

    // Vertical line if collapsed (+)
    if (!isExpanded) {
      canvas.drawLine(const Offset(4.5, 2), const Offset(4.5, 7), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _XPTreeTogglePainter oldDelegate) =>
      oldDelegate.isExpanded != isExpanded;
}

/// Draws classic Windows XP dotted connecting lines for nested tree nodes.
/// First level (depth 0) has NO vertical guide stem.
/// Toggle box + / - is stacked directly ON TOP of the branch join line.
class _XPTreeDottedConnectorPainter extends CustomPainter {
  final int depth;
  final bool isLastChild;

  const _XPTreeDottedConnectorPainter({
    required this.depth,
    this.isLastChild = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (depth <= 0) return;

    final paint = Paint()
      ..color = const Color(0xFF808080)
      ..strokeWidth = 1.0;

    // Stem X position for parent list level
    final stemX = ((depth - 1) * 16 + 4.5).toDouble();
    const rowCenterY = 12.0;

    // Vertical stem line (stops at rowCenterY if last child per CSS :last-child::after)
    final maxY = isLastChild ? rowCenterY : size.height;
    for (double dy = 0; dy <= maxY; dy += 2) {
      canvas.drawPixel(Offset(stemX, dy), paint);
    }

    // Horizontal branch line to node (length 12px)
    for (double dx = stemX; dx <= stemX + 12; dx += 2) {
      canvas.drawPixel(Offset(dx, rowCenterY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _XPTreeDottedConnectorPainter oldDelegate) =>
      oldDelegate.depth != depth || oldDelegate.isLastChild != isLastChild;
}

extension on Canvas {
  void drawPixel(Offset offset, Paint paint) {
    drawRect(Rect.fromLTWH(offset.dx, offset.dy, 1, 1), paint);
  }
}
