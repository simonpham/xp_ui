import 'dart:math' as math;
import 'package:flutter/widgets.dart';

import '../theme/xp_theme.dart';

/// Low-level custom painter for Windows XP Window borders and title bar background.
class XPWindowPainter extends CustomPainter {
  final double radius;

  XPWindowPainter({this.radius = 8.0});

  @override
  void paint(Canvas canvas, Size size) {
    // 3 concentric layers matching XP.css box-shadow:
    // inset -1px -1px #00138c, inset 1px 1px #0831d9,
    // inset -2px -2px #001ea0, inset 2px 2px #166aee,
    // inset -3px -3px #003bda, inset 3px 3px #0855dd
    final topColors = [
      const Color(0xFF0831D9),
      const Color(0xFF166AEE),
      const Color(0xFF0855DD),
    ];
    final bottomColors = [
      const Color(0xFF00138C),
      const Color(0xFF001EA0),
      const Color(0xFF003BDA),
    ];

    for (int i = 0; i < 3; i++) {
      final inset = i.toDouble();
      final rect = Rect.fromLTWH(
        inset,
        inset,
        math.max(0, size.width - inset * 2),
        math.max(0, size.height - inset * 2),
      );
      final r = math.max(0.0, radius - inset);

      final topPaint = Paint()
        ..color = topColors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final bottomPaint = Paint()
        ..color = bottomColors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      // Top & Left edge path (rounded top-left and top-right corners)
      final topLeftPath = Path()
        ..moveTo(rect.left + 0.5, rect.bottom - 0.5)
        ..lineTo(rect.left + 0.5, rect.top + r)
        ..arcToPoint(Offset(rect.left + r, rect.top + 0.5), radius: Radius.circular(r))
        ..lineTo(rect.right - r, rect.top + 0.5)
        ..arcToPoint(Offset(rect.right - 0.5, rect.top + r), radius: Radius.circular(r));

      canvas.drawPath(topLeftPath, topPaint);

      // Bottom & Right edge path (square bottom-left and bottom-right corners)
      final bottomRightPath = Path()
        ..moveTo(rect.right - 0.5, rect.top + r)
        ..lineTo(rect.right - 0.5, rect.bottom - 0.5)
        ..lineTo(rect.left + 0.5, rect.bottom - 0.5);

      canvas.drawPath(bottomRightPath, bottomPaint);
    }
  }

  @override
  bool shouldRepaint(covariant XPWindowPainter oldDelegate) =>
      oldDelegate.radius != radius;
}


/// Enum representing window control button types.
enum XPWindowButtonType { minimize, maximize, restore, help, close }

/// Low-level custom painter for XP Button background, borders, and glows.
/// Matches _buttons.scss exactly:
///   border: 1px solid #003c74
///   background: gradient (white 0%, #ECEBE5 86%, #D8D0C4 100%)
///   active: gradient (#CDCAC3 0%, #E3E3DB 8%, #E5E5DE 94%, #F2F2F1 100%)
///   hover: inset -1px 1px #fff0cf, inset 1px 2px #fdd889, inset -2px 2px #fbc761, inset 2px -2px #e5a01a
///   focus: inset -1px 1px #cee7ff, inset 1px 2px #98b8ea, inset -2px 2px #bcd4f6, inset 1px -1px #89ade4, inset 2px -2px #89ade4
class XPButtonPainter extends CustomPainter {
  final bool isHovered;
  final bool isActive;
  final bool isFocused;
  final bool isDisabled;

  XPButtonPainter({
    required this.isHovered,
    required this.isActive,
    required this.isFocused,
    required this.isDisabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3.0));

    if (isDisabled) {
      // Disabled: XP.css button disabled shows same normal gradient, text is grayed.
      // Border stays #003c74 (same button border).
      const disabledGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFFFF), Color(0xFFECEBE5), Color(0xFFD8D0C4)],
        stops: [0.0, 0.86, 1.0],
      );
      canvas.drawRRect(rrect, Paint()..shader = disabledGradient.createShader(rect));
      canvas.drawRRect(
        rrect.deflate(0.5),
        Paint()
          ..color = XPColors.buttonBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      return;
    }

    // Background gradient fill
    final LinearGradient gradient;
    if (isActive) {
      // active: rgba(205,202,195) 0%, rgba(227,227,219) 8%, rgba(229,229,222) 94%, rgba(242,242,241) 100%
      gradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFCDCAC3),
          Color(0xFFE3E3DB),
          Color(0xFFE5E5DE),
          Color(0xFFF2F2F1),
        ],
        stops: [0.0, 0.08, 0.94, 1.0],
      );
    } else {
      // normal: rgba(255,255,255) 0%, rgba(236,235,229) 86%, rgba(216,208,196) 100%
      gradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFECEBE5),
          Color(0xFFD8D0C4),
        ],
        stops: [0.0, 0.86, 1.0],
      );
    }
    canvas.drawRRect(rrect, Paint()..shader = gradient.createShader(rect));

    // Outer border: 1px solid #003c74
    canvas.drawRRect(
      rrect.deflate(0.5),
      Paint()
        ..color = XPColors.buttonBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    if (isHovered && !isActive) {
      // hover box-shadow:
      //   inset -1px 1px #fff0cf, inset 1px 2px #fdd889, inset -2px 2px #fbc761, inset 2px -2px #e5a01a
      _drawInsetShadow(canvas, size, 1, 1, 1, const Color(0xFFFFF0CF));
      _drawInsetShadow(canvas, size, 1, 2, 1, const Color(0xFFFDD889));
      _drawInsetShadow(canvas, size, 2, 2, 1, const Color(0xFFFBC761));
      _drawInsetShadow(canvas, size, -2, -2, 1, const Color(0xFFE5A01A));
      _drawInsetShadow(canvas, size, -1, -1, 1, const Color(0xFFE5A01A));
    } else if (isFocused && !isActive) {
      // focus box-shadow:
      //   inset -1px 1px #cee7ff, inset 1px 2px #98b8ea,
      //   inset -2px 2px #bcd4f6, inset 1px -1px #89ade4, inset 2px -2px #89ade4
      _drawInsetShadow(canvas, size, 1, 1, 1, const Color(0xFFCEE7FF));
      _drawInsetShadow(canvas, size, 1, 2, 1, const Color(0xFF98B8EA));
      _drawInsetShadow(canvas, size, 2, 2, 1, const Color(0xFFBCD4F6));
      _drawInsetShadow(canvas, size, 1, -1, 1, const Color(0xFF89ADE4));
      _drawInsetShadow(canvas, size, -1, -1, 1, const Color(0xFF89ADE4));
      _drawInsetShadow(canvas, size, -2, -2, 1, const Color(0xFF89ADE4));

      // focus dotted inner border (CSS outline: 1px dotted #000000; outline-offset: -4px)
      const XPDottedBorderPainter(color: Color(0xFF000000), inset: 3.0)
          .paint(canvas, size);
    }
  }

  /// Approximates CSS `inset Xpx Ypx color` by drawing inset lines from edges.
  void _drawInsetShadow(
      Canvas canvas, Size size, double x, double y, double strokeW, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW.abs();

    if (x > 0) {
      // left inset line
      canvas.drawLine(
          Offset(x + 0.5, y.abs()), Offset(x + 0.5, size.height - y.abs()), paint);
    } else if (x < 0) {
      // right inset line
      final rx = size.width + x - 0.5;
      canvas.drawLine(Offset(rx, y.abs()), Offset(rx, size.height - y.abs()), paint);
    }
    if (y > 0) {
      // top inset line
      canvas.drawLine(Offset(x.abs(), y + 0.5), Offset(size.width - x.abs(), y + 0.5), paint);
    } else if (y < 0) {
      // bottom inset line
      final by = size.height + y - 0.5;
      canvas.drawLine(Offset(x.abs(), by), Offset(size.width - x.abs(), by), paint);
    }
  }


  @override
  bool shouldRepaint(covariant XPButtonPainter oldDelegate) {
    return oldDelegate.isHovered != isHovered ||
        oldDelegate.isActive != isActive ||
        oldDelegate.isFocused != isFocused ||
        oldDelegate.isDisabled != isDisabled;
  }
}

/// Low-level custom painter for XP Progress Bar.
class XPProgressBarPainter extends CustomPainter {
  final double? value; // null for indeterminate
  final double animationOffset; // 0.0 to 1.0 for indeterminate animation

  XPProgressBarPainter({
    this.value,
    this.animationOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final innerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(innerRect, const Radius.circular(2.0)));


    const blockWidth = 8.0;
    const gapWidth = 2.0;
    const step = blockWidth + gapWidth;

    const blockGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: XPColors.progressBarGradient,
    );

    if (value != null) {
      // Determinate progress
      final fillWidth = innerRect.width * value!.clamp(0.0, 1.0);
      double x = innerRect.left;

      while (x < innerRect.left + fillWidth) {
        final w = math.min(blockWidth, innerRect.left + fillWidth - x);
        final blockRect = Rect.fromLTWH(x, innerRect.top, w, innerRect.height);
        canvas.drawRect(
          blockRect,
          Paint()..shader = blockGradient.createShader(blockRect),
        );
        x += step;
      }
    } else {
      // Indeterminate sliding progress (group of 3 blocks sliding across)
      final totalWidth = innerRect.width + step * 4;
      final startX = innerRect.left - step * 3 + totalWidth * animationOffset;

      for (int i = 0; i < 3; i++) {
        final x = startX + i * step;
        if (x + blockWidth > innerRect.left && x < innerRect.right) {
          final blockRect = Rect.fromLTWH(
            x,
            innerRect.top,
            blockWidth,
            innerRect.height,
          );
          canvas.drawRect(
            blockRect,
            Paint()..shader = blockGradient.createShader(blockRect),
          );
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant XPProgressBarPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.animationOffset != animationOffset;
  }
}

/// Custom painter for XP Checkbox box background and inner shadows.
class XPCheckboxPainter extends CustomPainter {
  final bool isHovered;
  final bool isPressed;
  final bool isDisabled;

  XPCheckboxPainter({
    required this.isHovered,
    required this.isPressed,
    required this.isDisabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (isDisabled) {
      // background: white, border: 1px solid #cac8bb
      canvas.drawRect(rect, Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawRect(
        rect.deflate(0.5),
        Paint()
          ..color = const Color(0xFFCAC8BB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      return;
    }

    // Background Fill
    final Gradient bgGradient;
    if (isPressed) {
      bgGradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFB0B0A7), Color(0xFFE3E1D2)],
      );
    } else {
      bgGradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFDCDCD7), Color(0xFFFFFFFF)],
      );
    }
    canvas.drawRect(rect, Paint()..shader = bgGradient.createShader(rect));

    // Inner Hover Shadow: inset -2px -2px #f8b636, inset 2px 2px #fedf9c
    if (isHovered && !isPressed) {
      // Top-left 2px inner glow (#FEDF9C)
      final topLeftPaint = Paint()
        ..color = const Color(0xFFFEDF9C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(const Offset(1.5, 1.5), Offset(size.width - 1.5, 1.5), topLeftPaint);
      canvas.drawLine(const Offset(1.5, 1.5), Offset(1.5, size.height - 1.5), topLeftPaint);
      canvas.drawLine(const Offset(2.5, 2.5), Offset(size.width - 2.5, 2.5), topLeftPaint);
      canvas.drawLine(const Offset(2.5, 2.5), Offset(2.5, size.height - 2.5), topLeftPaint);

      // Bottom-right 2px inner shadow (#F8B636)
      final bottomRightPaint = Paint()
        ..color = const Color(0xFFF8B636)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(size.width - 1.5, 1.5), Offset(size.width - 1.5, size.height - 1.5), bottomRightPaint);
      canvas.drawLine(Offset(1.5, size.height - 1.5), Offset(size.width - 1.5, size.height - 1.5), bottomRightPaint);
      canvas.drawLine(Offset(size.width - 2.5, 2.5), Offset(size.width - 2.5, size.height - 2.5), bottomRightPaint);
      canvas.drawLine(Offset(2.5, size.height - 2.5), Offset(size.width - 2.5, size.height - 2.5), bottomRightPaint);
    }

    // Outer border: 1px solid #1d5281
    canvas.drawRect(
      rect.deflate(0.5),
      Paint()
        ..color = const Color(0xFF1D5281)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant XPCheckboxPainter oldDelegate) {
    return oldDelegate.isHovered != isHovered ||
        oldDelegate.isPressed != isPressed ||
        oldDelegate.isDisabled != isDisabled;
  }
}

/// Custom painter for XP Radio button background and inner shadows.
class XPRadioPainter extends CustomPainter {
  final bool isHovered;
  final bool isPressed;
  final bool isDisabled;

  XPRadioPainter({
    required this.isHovered,
    required this.isPressed,
    required this.isDisabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (isDisabled) {
      // background: white, border: 1px solid #cac8bb
      canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawCircle(
        center,
        radius - 0.5,
        Paint()
          ..color = const Color(0xFFCAC8BB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      return;
    }

    // Background Fill
    final Gradient bgGradient;
    if (isPressed) {
      bgGradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFB0B0A7), Color(0xFFE3E1D2)],
      );
    } else {
      bgGradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFDCDCD7), Color(0xFFFFFFFF)],
      );
    }
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawCircle(center, radius, Paint()..shader = bgGradient.createShader(rect));

    // Inner Hover Shadow: inset -2px -2px #f8b636, inset 2px 2px #fedf9c
    if (isHovered && !isPressed) {
      canvas.save();
      canvas.clipPath(Path()..addOval(rect));

      final topLeftPaint = Paint()
        ..color = const Color(0xFFFEDF9C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawArc(
        rect.deflate(1.0),
        math.pi * 0.75,
        math.pi,
        false,
        topLeftPaint,
      );

      final bottomRightPaint = Paint()
        ..color = const Color(0xFFF8B636)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawArc(
        rect.deflate(1.0),
        -math.pi * 0.25,
        math.pi,
        false,
        bottomRightPaint,
      );

      canvas.restore();
    }

    // Outer border: 1px solid #1d5281
    canvas.drawCircle(
      center,
      radius - 0.5,
      Paint()
        ..color = const Color(0xFF1D5281)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant XPRadioPainter oldDelegate) {
    return oldDelegate.isHovered != isHovered ||
        oldDelegate.isPressed != isPressed ||
        oldDelegate.isDisabled != isDisabled;
  }
}

/// Custom painter that draws authentic Windows XP 1px dotted focus outline
/// matching CSS outline: 1px dotted #000000 / Win32 DrawFocusRect.
class XPDottedBorderPainter extends CustomPainter {
  final Color color;
  final double inset;

  const XPDottedBorderPainter({
    this.color = const Color(0xFF000000),
    this.inset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final left = inset;
    final top = inset;
    final right = (size.width - 1.0 - inset).clamp(left, size.width);
    final bottom = (size.height - 1.0 - inset).clamp(top, size.height);

    // Top edge
    for (double x = left; x <= right; x += 2) {
      canvas.drawRect(Rect.fromLTWH(x.roundToDouble(), top.roundToDouble(), 1, 1), paint);
    }
    // Bottom edge
    for (double x = left; x <= right; x += 2) {
      canvas.drawRect(Rect.fromLTWH(x.roundToDouble(), bottom.roundToDouble(), 1, 1), paint);
    }
    // Left edge
    for (double y = top; y <= bottom; y += 2) {
      canvas.drawRect(Rect.fromLTWH(left.roundToDouble(), y.roundToDouble(), 1, 1), paint);
    }
    // Right edge
    for (double y = top; y <= bottom; y += 2) {
      canvas.drawRect(Rect.fromLTWH(right.roundToDouble(), y.roundToDouble(), 1, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant XPDottedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.inset != inset;
}





