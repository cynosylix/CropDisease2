import 'package:flutter/material.dart';

/// Minimal app launcher / splash logo: gradient background, centered card, eco icon.
/// Canvas concept: 1024x1024. Use in a 1024x1024 area or let it scale.
class AppLauncherLogo extends StatelessWidget {
  const AppLauncherLogo({super.key});

  static const Color _topGreen = Color(0xFF1B5E20);
  static const Color _bottomGreen = Color(0xFF2E7D32);
  static const Color _cardBg = Color(0xFFDDE7DA);
  static const Color _iconGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        final squareSize = size * 0.5;
        final radius = squareSize * 0.25;
        final iconSize = squareSize * 0.5;

        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_topGreen, _bottomGreen],
            ),
          ),
          child: Center(
            child: Container(
              width: squareSize,
              height: squareSize,
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(radius),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.eco_rounded,
                size: iconSize,
                color: _iconGreen,
              ),
            ),
          ),
        );
      },
    );
  }
}
