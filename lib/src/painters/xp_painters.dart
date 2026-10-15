import 'dart:math' as math;
import 'package:flutter/widgets.dart';

import '../theme/xp_theme.dart';

/// Low-level custom painter for Windows XP Window borders and title bar background.
class XPWindowPainter extends CustomPainter {
  /// Corner radius for the window frame (defaults to 8.0).
  final double radius;

  static const List<Color> _topColors = [
    Color(0xFF0831D9),
    Color(0xFF166AEE),
    Color(0xFF0855DD),
  ];
  static const List<Color> _bottomColors = [
    Color(0xFF00138C),
    Color(0xFF001EA0),
    Color(0xFF003BDA),
  ];

  /// Creates an [XPWindowPainter].
  const XPWindowPainter({this.radius = 8.0});

  @override
  void paint(Canvas canvas, Size size) {
    // 3 concentric layers matching XP.css box-shadow:
    // inset -1px -1px #00138c, inset 1px 1px #0831d9,
    // inset -2px -2px #001ea0, inset 2px 2px #166aee,
    // inset -3px -3px #003bda, inset 3px 3px #0855dd
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 3; i++) {
      final inset = i.toDouble();
      final rect = Rect.fromLTWH(
        inset,
        inset,
        math.max(0, size.width - inset * 2),
        math.max(0, size.height - inset * 2),
      );
      final r = math.max(0.0, radius - inset);

      // Top & Left edge path (rounded top-left and top-right corners)
      final topLeftPath = Path()
        ..moveTo(rect.left + 0.5, rect.bottom - 0.5)
        ..lineTo(rect.left + 0.5, rect.top + r)
        ..arcToPoint(Offset(rect.left + r, rect.top + 0.5),
            radius: Radius.circular(r))
        ..lineTo(rect.right - r, rect.top + 0.5)
        ..arcToPoint(Offset(rect.right - 0.5, rect.top + r),
            radius: Radius.circular(r));

      strokePaint.color = _topColors[i];
      canvas.drawPath(topLeftPath, strokePaint);

      // Bottom & Right edge path (square bottom-left and bottom-right corners)
      final bottomRightPath = Path()
        ..moveTo(rect.right - 0.5, rect.top + r)
        ..lineTo(rect.right - 0.5, rect.bottom - 0.5)
        ..lineTo(rect.left + 0.5, rect.bottom - 0.5);

      strokePaint.color = _bottomColors[i];
      canvas.drawPath(bottomRightPath, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant XPWindowPainter oldDelegate) =>
      oldDelegate.radius != radius;
}

/// Enum representing window control button types.
enum XPWindowButtonType {
  /// Minimize window button.
  minimize,

  /// Maximize window button.
  maximize,

  /// Restore window button.
  restore,

  /// Help window button.
  help,

  /// Close window button.
  close,
}

/// Low-level custom painter for XP Button background, borders, and glows.
/// Matches _buttons.scss exactly:
///   border: 1px solid #003c74
///   background: gradient (white 0%, #ECEBE5 86%, #D8D0C4 100%)
///   active: gradient (#CDCAC3 0%, #E3E3DB 8%, #E5E5DE 94%, #F2F2F1 100%)
///   hover: inset -1px 1px #fff0cf, inset 1px 2px #fdd889, inset -2px 2px #fbc761, inset 2px -2px #e5a01a
///   focus: inset -1px 1px #cee7ff, inset 1px 2px #98b8ea, inset -2px 2px #bcd4f6, inset 1px -1px #89ade4, inset 2px -2px #89ade4
class XPButtonPainter extends CustomPainter {
  /// Whether button is in mouse hover state.
  final bool isHovered;

  /// Whether button is currently pressed/active.
  final bool isActive;

  /// Whether button has focus.
  final bool isFocused;

  /// Whether button is disabled.
  final bool isDisabled;

  static const LinearGradient _normalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: XPColors.buttonGradient,
    stops: XPColors.buttonGradientStops,
  );

  static const LinearGradient _activeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: XPColors.buttonActiveGradient,
    stops: XPColors.buttonActiveGradientStops,
  );

  static const LinearGradient _disabledGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFECEBE5), Color(0xFFD8D0C4)],
    stops: [0.0, 0.86, 1.0],
  );

  /// Creates an [XPButtonPainter].
  const XPButtonPainter({
    required this.isHovered,
    required this.isActive,
    required this.isFocused,
    required this.isDisabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3.0));
    final fillPaint = Paint();

    if (isDisabled) {
      // Disabled: XP.css button disabled shows normal gradient, text is grayed.
      fillPaint.shader = _disabledGradient.createShader(rect);
      canvas.drawRRect(rrect, fillPaint);
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
    final LinearGradient gradient =
        isActive ? _activeGradient : _normalGradient;
    fillPaint.shader = gradient.createShader(rect);
    canvas.drawRRect(rrect, fillPaint);

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
      final shadowPaint = Paint()..style = PaintingStyle.stroke;
      _drawInsetShadow(
          canvas, size, 1, 1, 1, const Color(0xFFFFF0CF), shadowPaint);
      _drawInsetShadow(
          canvas, size, 1, 2, 1, const Color(0xFFFDD889), shadowPaint);
      _drawInsetShadow(
          canvas, size, 2, 2, 1, const Color(0xFFFBC761), shadowPaint);
      _drawInsetShadow(
          canvas, size, -2, -2, 1, const Color(0xFFE5A01A), shadowPaint);
      _drawInsetShadow(
          canvas, size, -1, -1, 1, const Color(0xFFE5A01A), shadowPaint);
    } else if (isFocused && !isActive) {
      // focus box-shadow:
      //   inset -1px 1px #cee7ff, inset 1px 2px #98b8ea,
      //   inset -2px 2px #bcd4f6, inset 1px -1px #89ade4, inset 2px -2px #89ade4
      final shadowPaint = Paint()..style = PaintingStyle.stroke;
      _drawInsetShadow(
          canvas, size, 1, 1, 1, const Color(0xFFCEE7FF), shadowPaint);
      _drawInsetShadow(
          canvas, size, 1, 2, 1, const Color(0xFF98B8EA), shadowPaint);
      _drawInsetShadow(
          canvas, size, 2, 2, 1, const Color(0xFFBCD4F6), shadowPaint);
      _drawInsetShadow(
          canvas, size, 1, -1, 1, const Color(0xFF89ADE4), shadowPaint);
      _drawInsetShadow(
          canvas, size, -1, -1, 1, const Color(0xFF89ADE4), shadowPaint);
      _drawInsetShadow(
          canvas, size, -2, -2, 1, const Color(0xFF89ADE4), shadowPaint);

      // focus dotted inner border (CSS outline: 1px dotted #000000; outline-offset: -4px)
      const XPDottedBorderPainter(color: Color(0xFF000000), inset: 3.0)
          .paint(canvas, size);
    }
  }

  /// Approximates CSS `inset Xpx Ypx color` by drawing inset lines from edges.
  void _drawInsetShadow(Canvas canvas, Size size, double x, double y,
      double strokeW, Color color, Paint paint) {
    paint
      ..color = color
      ..strokeWidth = strokeW.abs();

    if (x > 0) {
      canvas.drawLine(Offset(x + 0.5, y.abs()),
          Offset(x + 0.5, size.height - y.abs()), paint);
    } else if (x < 0) {
      final rx = size.width + x - 0.5;
      canvas.drawLine(
          Offset(rx, y.abs()), Offset(rx, size.height - y.abs()), paint);
    }
    if (y > 0) {
      canvas.drawLine(Offset(x.abs(), y + 0.5),
          Offset(size.width - x.abs(), y + 0.5), paint);
    } else if (y < 0) {
      final by = size.height + y - 0.5;
      canvas.drawLine(
          Offset(x.abs(), by), Offset(size.width - x.abs(), by), paint);
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
  /// Determinate value between 0.0 and 1.0, or null for indeterminate mode.
  final double? value;

  /// Animation progress between 0.0 and 1.0 for indeterminate animation.
  final double animationOffset;

  static const double _blockWidth = 8.0;
  static const double _gapWidth = 2.0;
  static const double _step = _blockWidth + _gapWidth;

  static const LinearGradient _blockGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: XPColors.progressBarGradient,
  );

  /// Creates an [XPProgressBarPainter].
  const XPProgressBarPainter({
    this.value,
    this.animationOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final innerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.save();
    canvas.clipRRect(
        RRect.fromRectAndRadius(innerRect, const Radius.circular(2.0)));

    final blockPaint = Paint();

    if (value != null) {
      // Determinate progress
      final fillWidth = innerRect.width * value!.clamp(0.0, 1.0);
      double x = innerRect.left;

      while (x < innerRect.left + fillWidth) {
        final w = math.min(_blockWidth, innerRect.left + fillWidth - x);
        final blockRect = Rect.fromLTWH(x, innerRect.top, w, innerRect.height);
        blockPaint.shader = _blockGradient.createShader(blockRect);
        canvas.drawRect(blockRect, blockPaint);
        x += _step;
      }
    } else {
      // Indeterminate sliding progress (group of 3 blocks sliding across)
      final totalWidth = innerRect.width + _step * 4;
      final startX = innerRect.left - _step * 3 + totalWidth * animationOffset;

      for (int i = 0; i < 3; i++) {
        final x = startX + i * _step;
        if (x + _blockWidth > innerRect.left && x < innerRect.right) {
          final blockRect = Rect.fromLTWH(
            x,
            innerRect.top,
            _blockWidth,
            innerRect.height,
          );
          blockPaint.shader = _blockGradient.createShader(blockRect);
          canvas.drawRect(blockRect, blockPaint);
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
  /// Whether checkbox is hovered by mouse.
  final bool isHovered;

  /// Whether checkbox is pressed down.
  final bool isPressed;

  /// Whether checkbox is disabled.
  final bool isDisabled;

  static const LinearGradient _pressedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB0B0A7), Color(0xFFE3E1D2)],
  );

  static const LinearGradient _normalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDCDCD7), Color(0xFFFFFFFF)],
  );

  /// Creates an [XPCheckboxPainter].
  const XPCheckboxPainter({
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
    final LinearGradient bgGradient =
        isPressed ? _pressedGradient : _normalGradient;
    canvas.drawRect(rect, Paint()..shader = bgGradient.createShader(rect));

    // Inner Hover Shadow: inset -2px -2px #f8b636, inset 2px 2px #fedf9c
    if (isHovered && !isPressed) {
      final topLeftPaint = Paint()
        ..color = const Color(0xFFFEDF9C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(
          const Offset(1.5, 1.5), Offset(size.width - 1.5, 1.5), topLeftPaint);
      canvas.drawLine(
          const Offset(1.5, 1.5), Offset(1.5, size.height - 1.5), topLeftPaint);
      canvas.drawLine(
          const Offset(2.5, 2.5), Offset(size.width - 2.5, 2.5), topLeftPaint);
      canvas.drawLine(
          const Offset(2.5, 2.5), Offset(2.5, size.height - 2.5), topLeftPaint);

      final bottomRightPaint = Paint()
        ..color = const Color(0xFFF8B636)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(size.width - 1.5, 1.5),
          Offset(size.width - 1.5, size.height - 1.5), bottomRightPaint);
      canvas.drawLine(Offset(1.5, size.height - 1.5),
          Offset(size.width - 1.5, size.height - 1.5), bottomRightPaint);
      canvas.drawLine(Offset(size.width - 2.5, 2.5),
          Offset(size.width - 2.5, size.height - 2.5), bottomRightPaint);
      canvas.drawLine(Offset(2.5, size.height - 2.5),
          Offset(size.width - 2.5, size.height - 2.5), bottomRightPaint);
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
  /// Whether radio button is hovered by mouse.
  final bool isHovered;

  /// Whether radio button is pressed down.
  final bool isPressed;

  /// Whether radio button is disabled.
  final bool isDisabled;

  static const LinearGradient _pressedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB0B0A7), Color(0xFFE3E1D2)],
  );

  static const LinearGradient _normalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDCDCD7), Color(0xFFFFFFFF)],
  );

  /// Creates an [XPRadioPainter].
  const XPRadioPainter({
    required this.isHovered,
    required this.isPressed,
    required this.isDisabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (isDisabled) {
      canvas.drawCircle(
          center, radius, Paint()..color = const Color(0xFFFFFFFF));
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
    final LinearGradient bgGradient =
        isPressed ? _pressedGradient : _normalGradient;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawCircle(
        center, radius, Paint()..shader = bgGradient.createShader(rect));

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
  /// Color of the dotted outline.
  final Color color;

  /// Inset from widget boundary in pixels.
  final double inset;

  /// Creates an [XPDottedBorderPainter].
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
      canvas.drawRect(
          Rect.fromLTWH(x.roundToDouble(), top.roundToDouble(), 1, 1), paint);
    }
    // Bottom edge
    for (double x = left; x <= right; x += 2) {
      canvas.drawRect(
          Rect.fromLTWH(x.roundToDouble(), bottom.roundToDouble(), 1, 1),
          paint);
    }
    // Left edge
    for (double y = top; y <= bottom; y += 2) {
      canvas.drawRect(
          Rect.fromLTWH(left.roundToDouble(), y.roundToDouble(), 1, 1), paint);
    }
    // Right edge
    for (double y = top; y <= bottom; y += 2) {
      canvas.drawRect(
          Rect.fromLTWH(right.roundToDouble(), y.roundToDouble(), 1, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant XPDottedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.inset != inset;
}
