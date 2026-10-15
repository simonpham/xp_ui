import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../painters/xp_painters.dart';
import '../svg/xp_svg_assets.dart';
import '../svg/xp_svg_image.dart';

/// Authentic Windows XP Slider / Range control widget matching XP.css.
///
/// Supports horizontal and vertical orientations, continuous or discrete stepped values,
/// and pointer or box indicators.
class XPSlider extends StatefulWidget {
  /// The current slider value.
  final double value;

  /// Minimum value of the slider (defaults to 0.0).
  final double min;

  /// Maximum value of the slider (defaults to 1.0).
  final double max;

  /// Number of discrete step divisions. If null, slider is continuous.
  final int? divisions;

  /// Callback invoked when slider value changes.
  final ValueChanged<double>? onChanged;

  /// Whether the slider is oriented vertically (defaults to false).
  final bool isVertical;

  /// Whether to use a rectangular box indicator instead of the arrow indicator.
  final bool hasBoxIndicator;

  /// Explicit width for the slider widget.
  final double? width;

  /// Explicit height for the slider widget.
  final double? height;

  /// Creates an [XPSlider].
  const XPSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    required this.onChanged,
    this.isVertical = false,
    this.hasBoxIndicator = false,
    this.width,
    this.height,
  })  : assert(min <= max, 'min must be less than or equal to max'),
        assert(divisions == null || divisions > 0, 'divisions must be > 0');

  @override
  State<XPSlider> createState() => _XPSliderState();
}

class _XPSliderState extends State<XPSlider> {
  bool _isFocused = false;

  void _updateValueFromOffset(Offset localPosition, Size size) {
    if (widget.onChanged == null || widget.max <= widget.min) return;

    double normalized;
    if (!widget.isVertical) {
      final trackWidth = size.width - 11;
      final dx = (localPosition.dx - 5.5).clamp(0.0, trackWidth);
      normalized = dx / trackWidth;
    } else {
      final trackHeight = size.height - 11;
      final dy = (localPosition.dy - 5.5).clamp(0.0, trackHeight);
      normalized = 1.0 - (dy / trackHeight);
    }

    double newValue = widget.min + (widget.max - widget.min) * normalized;

    if (widget.divisions != null && widget.divisions! > 0) {
      final stepSize = (widget.max - widget.min) / widget.divisions!;
      newValue =
          ((newValue - widget.min) / stepSize).round() * stepSize + widget.min;
    }

    newValue = newValue.clamp(widget.min, widget.max);
    widget.onChanged!(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final double defaultWidth = widget.isVertical ? 21.0 : 150.0;
    final double defaultHeight = widget.isVertical ? 150.0 : 21.0;

    final range = widget.max - widget.min;
    final normalizedValue =
        range > 0 ? ((widget.value - widget.min) / range).clamp(0.0, 1.0) : 0.0;

    return Focus(
      canRequestFocus: widget.onChanged != null,
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      onKeyEvent: (node, event) {
        if (widget.onChanged == null || event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }

        final step = widget.divisions != null && widget.divisions! > 0
            ? (widget.max - widget.min) / widget.divisions!
            : (widget.max - widget.min) / 10.0;

        double? targetValue;
        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.arrowRight ||
            key == LogicalKeyboardKey.arrowUp) {
          targetValue = widget.value + step;
        } else if (key == LogicalKeyboardKey.arrowLeft ||
            key == LogicalKeyboardKey.arrowDown) {
          targetValue = widget.value - step;
        } else if (key == LogicalKeyboardKey.pageUp) {
          targetValue = widget.value + (widget.max - widget.min) * 0.2;
        } else if (key == LogicalKeyboardKey.pageDown) {
          targetValue = widget.value - (widget.max - widget.min) * 0.2;
        } else if (key == LogicalKeyboardKey.home) {
          targetValue = widget.min;
        } else if (key == LogicalKeyboardKey.end) {
          targetValue = widget.max;
        }

        if (targetValue != null) {
          final clamped = targetValue.clamp(widget.min, widget.max);
          widget.onChanged!(clamped);
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: CustomPaint(
        painter: _isFocused ? const XPDottedBorderPainter() : null,
        child: SizedBox(
          width: widget.width ?? defaultWidth,
          height: widget.height ?? defaultHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              final thumbX = 5.5 + (size.width - 11) * normalizedValue;
              final thumbY =
                  size.height - 5.5 - (size.height - 11) * normalizedValue;

              String svgString;
              if (widget.hasBoxIndicator) {
                svgString = XPSvgAssets.indicatorRectangleHorizontalSvg;
              } else {
                svgString = XPSvgAssets.indicatorHorizontalSvg;
              }

              return GestureDetector(
                onPanStart: (details) =>
                    _updateValueFromOffset(details.localPosition, size),
                onPanUpdate: (details) =>
                    _updateValueFromOffset(details.localPosition, size),
                onTapDown: (details) =>
                    _updateValueFromOffset(details.localPosition, size),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Track line
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _XPSliderTrackPainter(
                            isVertical: widget.isVertical),
                      ),
                    ),
                    // SVG Thumb
                    if (!widget.isVertical)
                      Positioned(
                        left: (thumbX - 5.5).clamp(0.0, size.width - 11),
                        top: (size.height - 21) / 2,
                        child: SizedBox(
                          width: 11,
                          height: 21,
                          child: XPSvgImage(svgString: svgString),
                        ),
                      )
                    else
                      Positioned(
                        left: (size.width - 11) / 2,
                        top: (thumbY - 10.5).clamp(0.0, size.height - 21),
                        child: Transform.rotate(
                          angle: 1.5707963267948966, // 90 degrees
                          child: SizedBox(
                            width: 11,
                            height: 21,
                            child: XPSvgImage(svgString: svgString),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _XPSliderTrackPainter extends CustomPainter {
  final bool isVertical;

  const _XPSliderTrackPainter({required this.isVertical});

  @override
  void paint(Canvas canvas, Size size) {
    final darkPaint = Paint()
      ..color = const Color(0xFF9D9C99)
      ..strokeWidth = 1.0;
    final whitePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 1.0;
    final bgPaint = Paint()..color = const Color(0xFFECEBE4);

    if (!isVertical) {
      final trackY = (size.height / 2).floorToDouble();
      final trackRect = Rect.fromLTWH(5.5, trackY - 1, size.width - 11, 2);

      // Track fill background: #ecebe4
      canvas.drawRect(trackRect, bgPaint);

      // Top & left dark shadow line: #9d9c99
      canvas.drawLine(
        Offset(trackRect.left - 1, trackRect.top - 1),
        Offset(trackRect.right + 1, trackRect.top - 1),
        darkPaint,
      );
      canvas.drawLine(
        Offset(trackRect.left - 1, trackRect.top - 1),
        Offset(trackRect.left - 1, trackRect.bottom + 1),
        darkPaint,
      );

      // Bottom & right white highlight line: #ffffff
      canvas.drawLine(
        Offset(trackRect.left - 1, trackRect.bottom + 1),
        Offset(trackRect.right + 1, trackRect.bottom + 1),
        whitePaint,
      );
      canvas.drawLine(
        Offset(trackRect.right + 1, trackRect.top - 1),
        Offset(trackRect.right + 1, trackRect.bottom + 1),
        whitePaint,
      );
    } else {
      final trackX = (size.width / 2).floorToDouble();
      final trackRect = Rect.fromLTWH(trackX - 1, 5.5, 2, size.height - 11);

      // Track fill background: #ecebe4
      canvas.drawRect(trackRect, bgPaint);

      // Top & right dark shadow line: #9d9c99
      canvas.drawLine(
        Offset(trackRect.left - 1, trackRect.top - 1),
        Offset(trackRect.right + 1, trackRect.top - 1),
        darkPaint,
      );
      canvas.drawLine(
        Offset(trackRect.right + 1, trackRect.top - 1),
        Offset(trackRect.right + 1, trackRect.bottom + 1),
        darkPaint,
      );

      // Bottom & left white highlight line: #ffffff
      canvas.drawLine(
        Offset(trackRect.left - 1, trackRect.bottom + 1),
        Offset(trackRect.right + 1, trackRect.bottom + 1),
        whitePaint,
      );
      canvas.drawLine(
        Offset(trackRect.left - 1, trackRect.top - 1),
        Offset(trackRect.left - 1, trackRect.bottom + 1),
        whitePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _XPSliderTrackPainter oldDelegate) =>
      oldDelegate.isVertical != isVertical;
}
