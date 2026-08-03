import 'package:flutter/widgets.dart';

import '../theme/xp_theme.dart';

/// Container widget that sets the default Windows XP surface background color
/// and text styling for its children.
class XPSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const XPSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = XPTheme.of(context);
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      color: theme.surface,
      child: DefaultTextStyle(
        style: theme.textStyle,
        child: child,
      ),
    );
  }
}
