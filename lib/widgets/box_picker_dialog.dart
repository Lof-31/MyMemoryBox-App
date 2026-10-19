import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

Future<int?> showBoxPickerDialog(
  BuildContext context, {
  String title = 'Move Card',
  int? currentLevel,
}) {
  final colors = context.colors;

  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 260,
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: List.generate(9, (level) {
            final bool isCurrent = level == currentLevel;
            final foreground = onBoxColor(colors, level);

            return Material(
              color: boxColor(colors, level),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: isCurrent
                    ? BorderSide(color: colors.onSurface, width: 3)
                    : BorderSide.none,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.pop(ctx, isCurrent ? null : level),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$level',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: foreground,
                      ),
                    ),
                    Text(
                      isCurrent ? 'current' : '${1 << level}d',
                      style: TextStyle(
                        fontSize: 12,
                        color: foreground.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
