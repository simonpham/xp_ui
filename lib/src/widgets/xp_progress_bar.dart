import 'package:flutter/widgets.dart';

import '../painters/xp_painters.dart';
import '../theme/xp_theme.dart';

/// A Windows XP styled Progress Bar widget.
/// Matches _progressbar.scss:
///   height: 14px, border: 1px solid #686868, border-radius: 4px,
///   padding: 1px 2px 1px 0px, background-color: white
///   blocks: 8px wide, 2px gap, green gradient
class XPProgressBar extends StatefulWidget {
  final double? value; // 0.0 to 1.0, or null for indeterminate mode
  final double width;
  final double height;

  const XPProgressBar({
    super.key,
    this.value,
    this.width = double.infinity,
    // --track-height: 14px
    this.height = 14,
  });

  @override
  State<XPProgressBar> createState() => _XPProgressBarState();
}

class _XPProgressBarState extends State<XPProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // --indeterminate-track-animation: sliding 2s linear 0s infinite
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.value == null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(XPProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: _XPProgressBarFramePainter(),
        child: Padding(
          // CSS: padding: 1px 2px 1px 0px; height: 14px;
          padding: const EdgeInsets.only(top: 1, bottom: 1, left: 1, right: 2),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: CustomPaint(
                  painter: XPProgressBarPainter(
                    value: widget.value,
                    animationOffset: _controller.value,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _XPProgressBarFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final outerRRect = RRect.fromRectAndRadius(rect.deflate(0.5), const Radius.circular(4));

    // Fill white track background
    canvas.drawRRect(outerRRect, Paint()..color = const Color(0xFFFFFFFF));

    // CSS: box-shadow: inset 0px 0px 1px 0px rgba(104, 104, 104, 1)
    final shadowRRect = RRect.fromRectAndRadius(rect.deflate(1.0), const Radius.circular(3));
    canvas.drawRRect(
      shadowRRect,
      Paint()
        ..color = const Color(0x40686868)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // CSS: border: 1px solid #686868
    canvas.drawRRect(
      outerRRect,
      Paint()
        ..color = XPColors.progressBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _XPProgressBarFramePainter oldDelegate) => false;
}




