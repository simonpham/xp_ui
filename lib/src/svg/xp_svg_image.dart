import 'package:flutter/widgets.dart';
import 'package:jovial_svg/jovial_svg.dart';

/// Renders SVG strings using jovial_svg with static caching for 60fps performance.
class XPSvgImage extends StatelessWidget {
  final String svgString;

  static final Map<String, ScalableImage> _cache = {};

  const XPSvgImage({
    super.key,
    required this.svgString,
  });

  @override
  Widget build(BuildContext context) {
    final ScalableImage si = _cache.putIfAbsent(
      svgString,
      () => ScalableImage.fromSvgString(svgString),
    );
    return ScalableImageWidget(si: si);
  }
}
