import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RilyColors {
  RilyColors._();

  static const bg = Color(0xFF0D0D14);
  static const surface = Color(0xFF16161F);
  static const surfaceElevated = Color(0xFF1E1E2A);
  static const surfaceBorder = Color(0xFF2A2A3A);

  static const accent = Color(0xFF6C63FF);
  static const accentLight = Color(0xFF8B85FF);
  static const accentDim = Color(0x266C63FF);

  static const success = Color(0xFF22C55E);
  static const successDim = Color(0x2022C55E);
  static const warning = Color(0xFFF59E0B);
  static const warningDim = Color(0x20F59E0B);
  static const error = Color(0xFFEF4444);
  static const errorDim = Color(0x20EF4444);
  static const info = Color(0xFF38BDF8);
  static const infoDim = Color(0x2038BDF8);

  static const statusCreated = Color(0xFF94A3B8);
  static const statusAccepted = Color(0xFF38BDF8);
  static const statusOnTheWay = Color(0xFFF59E0B);
  static const statusInProgress = Color(0xFFA78BFA);
  static const statusCompleted = Color(0xFF22C55E);
  static const statusCancelled = Color(0xFFEF4444);

  static const textPrimary = Color(0xFFF1F1F5);
  static const textSecondary = Color(0xFF8B8BA0);
  static const textMuted = Color(0xFF4A4A60);

  static const express = Color(0xFFFF6B35);
  static const expressDim = Color(0x20FF6B35);
}

class RilyTheme {
  RilyTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: RilyColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: RilyColors.accent,
        secondary: RilyColors.accentLight,
        surface: RilyColors.surface,
        error: RilyColors.error,
        onPrimary: Colors.white,
        onSurface: RilyColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: RilyColors.bg,
        foregroundColor: RilyColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: RilyColors.textPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: RilyColors.bg,
        ),
      ),
      cardTheme: CardThemeData(
  color: RilyColors.surface,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(color: RilyColors.surfaceBorder, width: 1),
  ),
  margin: EdgeInsets.zero,
),
    );
  }
}