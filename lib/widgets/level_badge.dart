import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LevelBadge extends StatelessWidget {
  final int level;
  final double size;

  const LevelBadge({super.key, required this.level, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: boxColor(context.colors, level),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$level',
        style: TextStyle(
          fontSize: size * 0.48,
          fontWeight: FontWeight.bold,
          color: onBoxColor(context.colors, level),
        ),
      ),
    );
  }
}
