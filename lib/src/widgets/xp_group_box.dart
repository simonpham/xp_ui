import 'package:flutter/widgets.dart';
import '../theme/xp_theme.dart';

/// Authentic Windows XP Fieldset / GroupBox widget matching XP.css.
///
/// Encloses child controls within an engraved 1px border (#D0D0BF)
/// with the characteristic blue legend title (#0046D5) breaking the top border.
class XPGroupBox extends StatefulWidget {
  /// Custom legend widget displayed on top of the fieldset border.
  final Widget? legend;

  /// String title for the legend if [legend] widget is not provided.
  final String? label;

  /// The child content contained within the group box.
  final Widget child;

  /// Inner padding inside the group box (defaults to `EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 8)`).
  final EdgeInsetsGeometry padding;

  /// Outer margin around the group box (defaults to `EdgeInsets.only(bottom: 9)`).
  final EdgeInsetsGeometry margin;

  /// Creates an [XPGroupBox].
  const XPGroupBox({
    super.key,
    this.legend,
    this.label,
    required this.child,
    this.padding = const EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 8),
    this.margin = const EdgeInsets.only(bottom: 9),
  });

  @override
  State<XPGroupBox> createState() => _XPGroupBoxState();
}

class _XPGroupBoxState extends State<XPGroupBox> {
  final GlobalKey _legendKey = GlobalKey();
  double _legendWidth = 0.0;
  bool _needsMeasurement = true;

  @override
  void initState() {
    super.initState();
    _calculateInitialWidth();
  }

  @override
  void didUpdateWidget(covariant XPGroupBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.label != oldWidget.label || widget.legend != oldWidget.legend) {
      _calculateInitialWidth();
      _needsMeasurement = true;
    }
  }

  void _calculateInitialWidth() {
    if (widget.label != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: widget.label!,
          style: const TextStyle(
            fontSize: 11,
            fontFamily: 'Arial',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      _legendWidth = textPainter.width + 4.0; // include 2px horizontal padding on each side
      _needsMeasurement = false;
    } else if (widget.legend != null) {
      _needsMeasurement = true;
    } else {
      _legendWidth = 0.0;
      _needsMeasurement = false;
    }
  }

  void _measureLegend() {
    final context = _legendKey.currentContext;
    if (context != null) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final w = renderBox.size.width;
        _needsMeasurement = false;
        if (w != _legendWidth && mounted) {
          setState(() {
            _legendWidth = w;
          });
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    Widget? legendWidget;
    if (widget.legend != null) {
      legendWidget = widget.legend;
    } else if (widget.label != null) {
      legendWidget = Text(
        widget.label!,
        style: const TextStyle(
          fontSize: 11,
          color: XPColors.legendColor,
          fontFamily: 'Arial',
        ),
      );
    }

    if (_needsMeasurement && legendWidget != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureLegend());
    }

    return Container(
      margin: widget.margin,
      child: Stack(
        children: [
          CustomPaint(
            painter: _XPGroupBoxBorderPainter(
              legendWidth: legendWidget != null ? _legendWidth : 0.0,
            ),
            child: Container(
              margin: EdgeInsets.only(top: legendWidget != null ? 7.0 : 0.0),
              padding: widget.padding,
              child: widget.child,
            ),
          ),
          if (legendWidget != null)
            Positioned(
              left: 10,
              top: 0,
              child: KeyedSubtree(
                key: _legendKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: legendWidget,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _XPGroupBoxBorderPainter extends CustomPainter {
  final double legendWidth;

  const _XPGroupBoxBorderPainter({required this.legendWidth});

  @override
  void paint(Canvas canvas, Size size) {
    const topInset = 7.0;
    final rect = Rect.fromLTWH(0, topInset, size.width, size.height - topInset);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(4.0));

    // fieldset { background: white } — fill with white before drawing border
    canvas.drawRRect(rRect, Paint()..color = const Color(0xFFFFFFFF));

    final paint = Paint()
      ..color = const Color(0xFFD0D0BF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (legendWidth <= 0) {
      canvas.drawRRect(rRect, paint);
      return;
    }

    const gapStart = 8.0;
    final gapEnd = gapStart + legendWidth + 4.0;

    final path = Path()
      ..moveTo(gapEnd, topInset)
      ..lineTo(rect.right - 4.0, topInset)
      ..arcToPoint(Offset(rect.right, topInset + 4.0), radius: const Radius.circular(4.0))
      ..lineTo(rect.right, rect.bottom - 4.0)
      ..arcToPoint(Offset(rect.right - 4.0, rect.bottom), radius: const Radius.circular(4.0))
      ..lineTo(rect.left + 4.0, rect.bottom)
      ..arcToPoint(Offset(rect.left, rect.bottom - 4.0), radius: const Radius.circular(4.0))
      ..lineTo(rect.left, topInset + 4.0)
      ..arcToPoint(Offset(rect.left + 4.0, topInset), radius: const Radius.circular(4.0))
      ..lineTo(gapStart, topInset);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _XPGroupBoxBorderPainter oldDelegate) =>
      oldDelegate.legendWidth != legendWidth;
}

/// Horizontal field layout helper (Row with 6px spacing).
class XPFieldRow extends StatelessWidget {
  /// Children widgets to layout in a row.
  final List<Widget> children;

  /// Main axis alignment.
  final MainAxisAlignment mainAxisAlignment;

  /// Cross axis alignment.
  final CrossAxisAlignment crossAxisAlignment;

  /// Creates an [XPFieldRow].
  const XPFieldRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      if (i > 0) spacedChildren.add(const SizedBox(width: 6));
      spacedChildren.add(children[i]);
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: spacedChildren,
    );
  }
}

/// Vertical field layout helper (Column with 6px spacing).
class XPFieldRowStacked extends StatelessWidget {
  /// Children widgets to layout vertically.
  final List<Widget> children;

  /// Main axis alignment.
  final MainAxisAlignment mainAxisAlignment;

  /// Cross axis alignment.
  final CrossAxisAlignment crossAxisAlignment;

  /// Explicit width constraint.
  final double? width;

  /// Creates an [XPFieldRowStacked].
  const XPFieldRowStacked({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      if (i > 0) spacedChildren.add(const SizedBox(height: 6));
      spacedChildren.add(children[i]);
    }

    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: spacedChildren,
      ),
    );
  }
}

