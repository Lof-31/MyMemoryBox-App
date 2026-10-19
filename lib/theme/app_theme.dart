import 'package:flutter/material.dart';

/// Couleurs sémantiques absentes du ColorScheme (succès, série de jours).
/// Générées à partir d'une graine pour rester lisibles en clair comme en sombre.
class AppColors extends ThemeExtension<AppColors> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color streak;
  final Color streakContainer;

  const AppColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.streak,
    required this.streakContainer,
  });

  factory AppColors.of(Brightness brightness) {
    final green = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D32),
      brightness: brightness,
    );
    final amber = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF8F00),
      brightness: brightness,
    );
    return AppColors(
      success: green.primary,
      onSuccess: green.onPrimary,
      successContainer: green.primaryContainer,
      onSuccessContainer: green.onPrimaryContainer,
      streak: amber.primary,
      streakContainer: amber.primaryContainer,
    );
  }

  @override
  AppColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? streak,
    Color? streakContainer,
  }) {
    return AppColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      streak: streak ?? this.streak,
      streakContainer: streakContainer ?? this.streakContainer,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      streak: Color.lerp(streak, other.streak, t)!,
      streakContainer: Color.lerp(streakContainer, other.streakContainer, t)!,
    );
  }
}

ThemeData buildAppTheme(Color seedColor, Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );
  // Couleur choisie dans Settings, adoucie en la mélangeant au fond de page
  final fabColor = Color.alphaBlend(
    seedColor.withValues(alpha: 0.5),
    colorScheme.surface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    extensions: [AppColors.of(brightness)],
    // Cartes en aplat : le contraste vient du fond, pas de l'ombre
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 2,
      backgroundColor: fabColor,
      foregroundColor:
          ThemeData.estimateBrightnessForColor(fabColor) == Brightness.dark
              ? Colors.white
              : Colors.black87,
    ),
  );
}

/// Dégradé des 9 boîtes dérivé de la couleur du thème :
/// de la plus claire (boîte 0) à la plus intense (boîte 8).
/// En mode sombre, l'intensité va du sombre vers le lumineux.
Color boxColor(ColorScheme colorScheme, int level) {
  final hsl = HSLColor.fromColor(colorScheme.primary);
  final t = level.clamp(0, 8) / 8;
  final bool isDark = colorScheme.brightness == Brightness.dark;
  final lightness = isDark ? 0.30 + 0.45 * t : 0.80 - 0.52 * t;
  final saturation = hsl.saturation < 0.55 ? 0.55 : hsl.saturation;
  return hsl.withLightness(lightness).withSaturation(saturation).toColor();
}

Color onBoxColor(ColorScheme colorScheme, int level) {
  final bg = boxColor(colorScheme, level);
  return ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
      ? Colors.white
      : Colors.black87;
}

extension AppThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
