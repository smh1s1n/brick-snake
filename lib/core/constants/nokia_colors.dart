import 'package:flutter/material.dart';

/// Authentic Nokia Monochrome LCD palettes.
class NokiaColors {
  // Classic Nokia 1100 Green Backlight
  static const Color lcdScreenBg = Color(0xFF98A62F); // Light olive green lit LCD
  static const Color lcdScreenBgOff = Color(0xFF7A8625); // Slightly darker unlit LCD
  static const Color lcdScreenBgDark = Color(0xFF8B9928);
  static const Color lcdPixelOn = Color(0xFF0F1A07); // Very dark forest black pixel
  static const Color lcdPixelGhost = Color(0x180F1A07); // Ghost pixel shadow for authentic matrix

  // Optional Retro Amber/Orange Backlight (Nokia 3310 style)
  static const Color lcdAmberBg = Color(0xFFDCA434);
  static const Color lcdAmberPixelOn = Color(0xFF2B1804);

  // Classic Monochrome (Grey)
  static const Color lcdMonoBg = Color(0xFF8E9982);
  static const Color lcdMonoPixelOn = Color(0xFF1B2117);

  // Nokia 1100 Physical Casing Colors
  static const Color casingOuterBlue = Color(0xFF3B4E5F); // Classic Nokia 1100 slate blue
  static const Color casingOuterGrey = Color(0xFF4A4D52);
  static const Color casingBezel = Color(0xFF262A2E); // Dark surround around the screen
  static const Color casingRubberKey = Color(0xFFCED2D9); // Silicone light grey keys
  static const Color casingKeyText = Color(0xFF1E242B);
  static const Color casingKeyNavi = Color(0xFF2E7B99); // Navi-key cyan/blue accent
  static const Color casingKeyAccent = Color(0xFFD43833); // Red hangup accent
}

enum ScreenTheme {
  classicGreen,
  retroAmber,
  monochromeGrey,
}

extension ScreenThemeExtension on ScreenTheme {
  Color get backgroundColor {
    switch (this) {
      case ScreenTheme.classicGreen:
        return NokiaColors.lcdScreenBg;
      case ScreenTheme.retroAmber:
        return NokiaColors.lcdAmberBg;
      case ScreenTheme.monochromeGrey:
        return NokiaColors.lcdMonoBg;
    }
  }

  Color get pixelColor {
    switch (this) {
      case ScreenTheme.classicGreen:
        return NokiaColors.lcdPixelOn;
      case ScreenTheme.retroAmber:
        return NokiaColors.lcdAmberPixelOn;
      case ScreenTheme.monochromeGrey:
        return NokiaColors.lcdMonoPixelOn;
    }
  }

  String get displayName {
    switch (this) {
      case ScreenTheme.classicGreen:
        return 'Nokia Green';
      case ScreenTheme.retroAmber:
        return 'Nokia Amber';
      case ScreenTheme.monochromeGrey:
        return 'Classic Mono';
    }
  }
}
