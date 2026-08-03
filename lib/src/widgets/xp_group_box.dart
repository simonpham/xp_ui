import 'package:flutter/widgets.dart';
import '../theme/xp_theme.dart';

/// Authentic Windows XP Fieldset / GroupBox widget matching XP.css.
class XPGroupBox extends StatefulWidget {
  final Widget? legend;
  final String? label;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

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

  void _measureLegend() {
    final context = _legendKey.currentContext;
    if (context != null) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final w = renderBox.size.width;
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

    if (legendWidget != null && _legendWidth == 0.0) {
      // Synchronous TextPainter estimation for initial render frame to avoid 1-frame gap jump
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
        _legendWidth = textPainter.width;
      }
    }

    // Schedule post-frame measurement for dynamic legend widgets
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureLegend());

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

  _XPGroupBoxBorderPainter({required this.legendWidth});

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
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

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
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double? width;

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
