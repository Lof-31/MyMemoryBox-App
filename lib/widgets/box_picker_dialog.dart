import 'package:flutter/material.dart';

/// Affiche une grille des 9 boîtes et renvoie le niveau choisi (null si annulé).
Future<int?> showBoxPickerDialog(
  BuildContext context, {
  String title = 'Move Card',
  int? currentLevel,
}) {
  final primaryColor = Theme.of(context).colorScheme.primary;

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

            return Material(
              color: isCurrent
                  ? primaryColor
                  : primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
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
                        color: isCurrent ? Colors.white : primaryColor,
                      ),
                    ),
                    Text(
                      '${1 << level}d',
                      style: TextStyle(
                        fontSize: 12,
                        color: isCurrent ? Colors.white70 : Colors.grey.shade700,
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
