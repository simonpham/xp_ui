import 'package:flutter/widgets.dart';

import '../theme/xp_theme.dart';

/// Authentic 3D Vertical Divider matching XP.css vertical-bar.
class XPVerticalDivider extends StatelessWidget {
  final double height;
  final double width;

  const XPVerticalDivider({
    super.key,
    this.height = 20.0,
    this.width = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFFC0C0C0),
        boxShadow: [
          BoxShadow(
            color: XPColors.windowFrame,
            offset: Offset(-1, -1),
          ),
          BoxShadow(
            color: XPColors.buttonHighlight,
            offset: Offset(1, 1),
          ),
          BoxShadow(
            color: XPColors.buttonShadow,
            offset: Offset(-2, -2),
          ),
          BoxShadow(
            color: XPColors.buttonFace,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );
  }
}

/// Authentic 3D Horizontal Divider.
class XPHorizontalDivider extends StatelessWidget {
  final double? width;
  final EdgeInsetsGeometry margin;

  const XPHorizontalDivider({
    super.key,
    this.width,
    this.margin = const EdgeInsets.symmetric(vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 2,
      margin: margin,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF808080), width: 1),
          bottom: BorderSide(color: Color(0xFFFFFFFF), width: 1),
        ),
      ),
    );
  }
}
