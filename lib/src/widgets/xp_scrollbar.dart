import 'package:flutter/widgets.dart';
import '../svg/xp_svg_assets.dart';
import '../svg/xp_svg_image.dart';

/// Authentic Windows XP styled Scrollbar widget matching XP.css.
///
/// Features 17px SVG arrow buttons, #c8d6fb thumb with 1px white border and inset shadows,
/// and smooth scroll controller integration.
class XPScrollbar extends StatefulWidget {
  /// The scrollable child widget wrapped by this scrollbar.
  final Widget child;

  /// Optional external [ScrollController]. If omitted, an internal controller is used.
  final ScrollController? controller;

  /// The axis along which scrolling occurs (defaults to [Axis.vertical]).
  final Axis scrollDirection;

  /// Creates an [XPScrollbar].
  const XPScrollbar({
    super.key,
    required this.child,
    this.controller,
    this.scrollDirection = Axis.vertical,
  });


  @override
  State<XPScrollbar> createState() => _XPScrollbarState();
}

class _XPScrollbarState extends State<XPScrollbar> {
  ScrollController? _internalController;

  ScrollController get _effectiveController {
    if (widget.controller != null) return widget.controller!;
    return _internalController ??= ScrollController();
  }


  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  void _scrollBy(double offset) {
    if (!_effectiveController.hasClients) return;
    final target = (_effectiveController.offset + offset).clamp(
      0.0,
      _effectiveController.position.maxScrollExtent,
    );
    _effectiveController.animateTo(
      target,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVertical = widget.scrollDirection == Axis.vertical;

    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        Positioned(
          top: 0,
          right: 0,
          bottom: isVertical ? 0 : null,
          left: isVertical ? null : 0,
          height: isVertical ? null : 17,
          width: isVertical ? 17 : null,
          child: RepaintBoundary(
            child: ListenableBuilder(
              listenable: _effectiveController,
              builder: (context, _) {
                double scrollFraction = 0.0;
                double thumbExtent = 0.3;
                final isScrollable = _effectiveController.hasClients &&
                    _effectiveController.position.hasContentDimensions &&
                    _effectiveController.position.maxScrollExtent > 0;

                if (isScrollable) {
                  final maxExtent = _effectiveController.position.maxScrollExtent;
                  final currentOffset = _effectiveController.offset;
                  final viewportDimension = _effectiveController.position.viewportDimension;
                  scrollFraction = (currentOffset / maxExtent).clamp(0.0, 1.0);
                  thumbExtent = (viewportDimension / (maxExtent + viewportDimension)).clamp(0.1, 0.9);
                }

                if (isVertical) {
                  return Column(
                    children: [
                      XPScrollArrowButton(
                        direction: Axis.vertical,
                        isStart: true,
                        onPressed: isScrollable ? () => _scrollBy(-40) : null,
                      ),
                      Expanded(
                        child: Container(
                          color: const Color(0xFFDFE8FF),
                          child: CustomPaint(
                            painter: const _XPScrollbarTrackPainter(isVertical: true),
                            child: !isScrollable
                                ? const SizedBox.expand()
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      final trackHeight = constraints.maxHeight;
                                      final thumbHeight = (trackHeight * thumbExtent).clamp(20.0, trackHeight);
                                      final maxThumbTop = trackHeight - thumbHeight;
                                      final thumbTop = maxThumbTop * scrollFraction;

                                      return Stack(
                                        children: [
                                          Positioned(
                                            top: thumbTop,
                                            left: 0,
                                            width: 17,
                                            height: thumbHeight,
                                            child: GestureDetector(
                                              onVerticalDragUpdate: (details) {
                                                if (!_effectiveController.hasClients || maxThumbTop <= 0) return;
                                                final deltaFraction = details.delta.dy / maxThumbTop;
                                                final deltaOffset = deltaFraction * _effectiveController.position.maxScrollExtent;
                                                _effectiveController.jumpTo(
                                                  (_effectiveController.offset + deltaOffset).clamp(
                                                    0.0,
                                                    _effectiveController.position.maxScrollExtent,
                                                  ),
                                                );
                                              },
                                              child: const CustomPaint(
                                                painter: _XPScrollbarThumbPainter(isVertical: true),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                      XPScrollArrowButton(
                        direction: Axis.vertical,
                        isStart: false,
                        onPressed: isScrollable ? () => _scrollBy(40) : null,
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      XPScrollArrowButton(
                        direction: Axis.horizontal,
                        isStart: true,
                        onPressed: isScrollable ? () => _scrollBy(-40) : null,
                      ),
                      Expanded(
                        child: Container(
                          color: const Color(0xFFDFE8FF),
                          child: CustomPaint(
                            painter: const _XPScrollbarTrackPainter(isVertical: false),
                            child: !isScrollable
                                ? const SizedBox.expand()
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      final trackWidth = constraints.maxWidth;
                                      final thumbWidth = (trackWidth * thumbExtent).clamp(20.0, trackWidth);
                                      final maxThumbLeft = trackWidth - thumbWidth;
                                      final thumbLeft = maxThumbLeft * scrollFraction;

                                      return Stack(
                                        children: [
                                          Positioned(
                                            left: thumbLeft,
                                            top: 0,
                                            height: 17,
                                            width: thumbWidth,
                                            child: GestureDetector(
                                              onHorizontalDragUpdate: (details) {
                                                if (!_effectiveController.hasClients || maxThumbLeft <= 0) return;
                                                final deltaFraction = details.delta.dx / maxThumbLeft;
                                                final deltaOffset = deltaFraction * _effectiveController.position.maxScrollExtent;
                                                _effectiveController.jumpTo(
                                                  (_effectiveController.offset + deltaOffset).clamp(
                                                    0.0,
                                                    _effectiveController.position.maxScrollExtent,
                                                  ),
                                                );
                                              },
                                              child: const CustomPaint(
                                                painter: _XPScrollbarThumbPainter(isVertical: false),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                      XPScrollArrowButton(
                        direction: Axis.horizontal,
                        isStart: false,
                        onPressed: isScrollable ? () => _scrollBy(40) : null,
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _XPScrollbarTrackPainter extends CustomPainter {
  final bool isVertical;

  const _XPScrollbarTrackPainter({required this.isVertical});

  static final Paint _borderPaint = Paint()
    ..color = const Color(0xFFBDD0FB)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (isVertical) {
      canvas.drawLine(const Offset(0.5, 0), Offset(0.5, size.height), _borderPaint);
    } else {
      canvas.drawLine(const Offset(0, 0.5), Offset(size.width, 0.5), _borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _XPScrollbarTrackPainter oldDelegate) => false;
}

class _XPScrollbarThumbPainter extends CustomPainter {
  final bool isVertical;

  const _XPScrollbarThumbPainter({required this.isVertical});

  static final Paint _bgPaint = Paint()..color = const Color(0xFFC8D6FB);
  static final Paint _outerBorderPaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  static final Paint _shadowPaint1 = Paint()
    ..color = const Color(0xFFBAD1FC)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  static final Paint _shadowPaint2 = Paint()
    ..color = const Color(0xFFB7CAF5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  static final Paint _gripperPaint = Paint()
    ..color = const Color(0xFF5B81C9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Fill background: #c8d6fb
    canvas.drawRect(rect, _bgPaint);

    // Outer border: 1px solid white
    canvas.drawRect(rect.deflate(0.5), _outerBorderPaint);

    // Inset shadows matching scroll-thumb.svg
    if (isVertical) {
      canvas.drawLine(Offset(size.width - 1.5, 1), Offset(size.width - 1.5, size.height - 1), _shadowPaint1);
      canvas.drawLine(const Offset(1.5, 1), Offset(size.width - 1.5, 1), _shadowPaint2);
    } else {
      canvas.drawLine(Offset(1, size.height - 1.5), Offset(size.width - 1, size.height - 1.5), _shadowPaint1);
      canvas.drawLine(const Offset(1, 1.5), Offset(1, size.height - 1.5), _shadowPaint2);
    }

    // Center gripper lines (scroll-thumb.svg)
    if (isVertical && size.height >= 16) {
      final midY = (size.height / 2).floorToDouble();
      canvas.drawLine(Offset(4, midY - 3), Offset(13, midY - 3), _gripperPaint);
      canvas.drawLine(Offset(4, midY), Offset(13, midY), _gripperPaint);
      canvas.drawLine(Offset(4, midY + 3), Offset(13, midY + 3), _gripperPaint);
    } else if (!isVertical && size.width >= 16) {
      final midX = (size.width / 2).floorToDouble();
      canvas.drawLine(Offset(midX - 3, 4), Offset(midX - 3, 13), _gripperPaint);
      canvas.drawLine(Offset(midX, 4), Offset(midX, 13), _gripperPaint);
      canvas.drawLine(Offset(midX + 3, 4), Offset(midX + 3, 13), _gripperPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _XPScrollbarThumbPainter oldDelegate) =>
      oldDelegate.isVertical != isVertical;
}

/// Helper for rendering scrollbar arrow buttons matching ::-webkit-scrollbar-button (17px x 17px).
class XPScrollArrowButton extends StatelessWidget {
  /// The scroll orientation of the button.
  final Axis direction;

  /// Whether this is the start arrow (up/left) or end arrow (down/right).
  final bool isStart;

  /// Callback invoked when the button is tapped.
  final VoidCallback? onPressed;

  /// Creates an [XPScrollArrowButton].
  const XPScrollArrowButton({
    super.key,
    required this.direction,
    required this.isStart,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    String svgString;
    if (direction == Axis.vertical) {
      svgString = isStart ? XPSvgAssets.scrollArrowUpSvg : XPSvgAssets.scrollArrowDownSvg;
    } else {
      svgString = isStart ? XPSvgAssets.scrollArrowLeftSvg : XPSvgAssets.scrollArrowRightSvg;
    }

    return GestureDetector(
      onTap: onPressed,
      child: Opacity(
        opacity: onPressed != null ? 1.0 : 0.5,
        child: SizedBox(
          width: 17,
          height: 17,
          child: XPSvgImage(svgString: svgString),
        ),
      ),
    );
  }
}



