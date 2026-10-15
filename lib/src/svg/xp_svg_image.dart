import 'package:flutter/widgets.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'xp_svg_assets.dart';

/// Renders SVG strings using jovial_svg with static caching for high-performance 60fps rendering.
class XPSvgImage extends StatelessWidget {
  /// Raw SVG XML string to render.
  final String svgString;

  /// Optional fit property for SVG scaling.
  final BoxFit fit;

  static final Map<String, ScalableImage> _cache = <String, ScalableImage>{};

  /// Creates an [XPSvgImage] from an SVG string.
  const XPSvgImage({
    super.key,
    required this.svgString,
    this.fit = BoxFit.contain,
  });

  /// Pre-compiles and caches all embedded [XPSvgAssets] into memory.
  ///
  /// Calling this during app initialization prevents any compilation overhead
  /// during the first frame of widget rendering.
  static void preloadAll() {
    for (final svg in XPSvgAssets.all) {
      _cache.putIfAbsent(svg, () => ScalableImage.fromSvgString(svg));
    }
  }

  /// Clears the in-memory ScalableImage cache.
  static void clearCache() {
    _cache.clear();
  }

  @override
  Widget build(BuildContext context) {
    final ScalableImage si = _cache.putIfAbsent(
      svgString,
      () => ScalableImage.fromSvgString(svgString),
    );
    return ScalableImageWidget(si: si, fit: fit);
  }
}
