import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class FlutterFlowTheme {
  static FlutterFlowTheme of(BuildContext context) {
    return LightModeTheme();
  }

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  // GymRadar custom colors
  late Color hintText;
  late Color dividerColor;
  late Color cardBackground;
  late Color ratingColor;
  late Color distanceColor;
  late Color openColor;
  late Color closedColor;
  late Color chipBackground;
  late Color chipText;
  late Color shadowColor;
  late Color inputBorder;
  late Color inputFocusBorder;
  late Color transparent;
  late Color navBackground;
  late Color navSelected;
  late Color navUnselected;
  late Color tagBackground;
  late Color priceColor;

  String get displayLargeFamily => typography.displayLargeFamily;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends FlutterFlowTheme {
  // ── Paleta refinada (dark premium) ─────────────────────────────
  late Color primary = const Color(0xFF007AFF);       // azul iOS — primary
  late Color secondary = const Color(0xFF0A84FF);     // azul claro variante
  late Color tertiary = const Color(0xFFF5F5F5);
  late Color alternate = const Color(0xFF2A2A2A);
  late Color primaryText = const Color(0xFFF0F0F0);
  late Color secondaryText = const Color(0xFF888888);
  late Color primaryBackground = const Color(0xFF121212);
  late Color secondaryBackground = const Color(0xFF1C1C1E);
  late Color accent1 = const Color(0x22007AFF);
  late Color accent2 = const Color(0x220A84FF);
  late Color accent3 = const Color(0x22F5F5F5);
  late Color accent4 = const Color(0xCC121212);
  late Color success = const Color(0xFF34C759);
  late Color warning = const Color(0xFFFF9F0A);
  late Color error = const Color(0xFFFF453A);
  late Color info = const Color(0xFF64D2FF);

  late Color hintText = const Color(0xFF4A4A4A);
  late Color dividerColor = const Color(0xFF2C2C2E);
  late Color cardBackground = const Color(0xFF1C1C1E);
  late Color ratingColor = const Color(0xFFFF9F0A);
  late Color distanceColor = const Color(0xFF888888);
  late Color openColor = const Color(0xFF34C759);
  late Color closedColor = const Color(0xFFFF453A);
  late Color chipBackground = const Color(0xFF007AFF22);
  late Color chipText = const Color(0xFF007AFF);
  late Color shadowColor = const Color(0x60000000);
  late Color inputBorder = const Color(0xFF2C2C2E);
  late Color inputFocusBorder = const Color(0xFF007AFF);
  late Color transparent = const Color(0x00000000);
  late Color navBackground = const Color(0xFF1C1C1E);
  late Color navSelected = const Color(0xFF007AFF);
  late Color navUnselected = const Color(0xFF555555);
  late Color tagBackground = const Color(0xFF2C2C2E);
  late Color priceColor = const Color(0xFF007AFF);
}

abstract class Typography {
  String get displayLargeFamily;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);
  final FlutterFlowTheme theme;

  String get displayLargeFamily => 'Montserrat';
  TextStyle get displayLarge => TextStyle(color: theme.primaryText, fontWeight: FontWeight.w800, fontSize: 57.0);
  String get displayMediumFamily => 'Montserrat';
  TextStyle get displayMedium => TextStyle(color: theme.primaryText, fontWeight: FontWeight.w800, fontSize: 32.0);
  String get displaySmallFamily => 'Montserrat';
  TextStyle get displaySmall => TextStyle(color: theme.primaryText, fontWeight: FontWeight.w700, fontSize: 28.0);
  String get headlineLargeFamily => 'Montserrat';
  TextStyle get headlineLarge => TextStyle(color: theme.primaryText, fontWeight: FontWeight.w700, fontSize: 24.0);
  String get headlineMediumFamily => 'Montserrat';
  TextStyle get headlineMedium => TextStyle(color: theme.primaryText, fontWeight: FontWeight.w700, fontSize: 20.0);
  String get headlineSmallFamily => 'Montserrat';
  TextStyle get headlineSmall => TextStyle(color: theme.primaryText, fontWeight: FontWeight.w700, fontSize: 18.0);
  String get titleLargeFamily => 'Montserrat';
  TextStyle get titleLarge => TextStyle(color: theme.primaryText, fontWeight: FontWeight.w600, fontSize: 16.0);
  String get titleMediumFamily => 'Montserrat';
  TextStyle get titleMedium => TextStyle(color: theme.primaryText, fontWeight: FontWeight.w600, fontSize: 15.0);
  String get titleSmallFamily => 'Montserrat';
  TextStyle get titleSmall => TextStyle(color: theme.primaryText, fontWeight: FontWeight.w600, fontSize: 14.0);
  String get labelLargeFamily => 'Inter';
  TextStyle get labelLarge => TextStyle(color: theme.secondaryText, fontWeight: FontWeight.normal, fontSize: 14.0);
  String get labelMediumFamily => 'Inter';
  TextStyle get labelMedium => TextStyle(color: theme.secondaryText, fontWeight: FontWeight.normal, fontSize: 12.0);
  String get labelSmallFamily => 'Inter';
  TextStyle get labelSmall => TextStyle(color: theme.secondaryText, fontWeight: FontWeight.normal, fontSize: 11.0);
  String get bodyLargeFamily => 'Inter';
  TextStyle get bodyLarge => TextStyle(color: theme.primaryText, fontWeight: FontWeight.normal, fontSize: 16.0);
  String get bodyMediumFamily => 'Inter';
  TextStyle get bodyMedium => TextStyle(color: theme.primaryText, fontWeight: FontWeight.normal, fontSize: 14.0);
  String get bodySmallFamily => 'Inter';
  TextStyle get bodySmall => TextStyle(color: theme.primaryText, fontWeight: FontWeight.normal, fontSize: 12.0);
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
    String? package,
  }) {
    if (useGoogleFonts && fontFamily != null) {
      try {
        font = GoogleFonts.getFont(fontFamily,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle);
      } catch (_) {}
    }
    return font != null
        ? font.copyWith(
            color: color ?? this.color,
            fontSize: fontSize ?? this.fontSize,
            letterSpacing: letterSpacing ?? this.letterSpacing,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          )
        : copyWith(
            fontFamily: fontFamily,
            package: package,
            color: color,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          );
  }
}
