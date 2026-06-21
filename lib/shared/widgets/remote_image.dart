import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Cached network image with shimmer-free placeholder and graceful fallback.
/// Always use this instead of Image.network (Phase 11: performance).
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final image = url.isEmpty
        ? _fallback(scheme)
        : CachedNetworkImage(
            imageUrl: url,
            width: width,
            height: height,
            fit: fit,
            placeholder: (_, __) => Container(
              width: width,
              height: height,
              color: scheme.surfaceContainerHighest,
            ),
            errorWidget: (_, __, ___) => _fallback(scheme),
          );
    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }

  Widget _fallback(ColorScheme scheme) => Container(
        width: width,
        height: height,
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.restaurant, color: scheme.outline),
      );
}
