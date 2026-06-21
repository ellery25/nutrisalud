import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/assets.dart';

/// NutriSalud logo, tinted to fit the current surface.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 96, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    return SvgPicture.asset(
      AppAssets.logoSvg,
      height: size,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      semanticsLabel: 'NutriSalud logo',
    );
  }
}
