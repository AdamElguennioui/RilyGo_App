import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RilyColors {
  RilyColors._();

  // ── Backgrounds (deep navy) ───────────────────────────────────────────────
  static const bg              = Color(0xFF060E1B);
  static const surface         = Color(0xFF0B1629);
  static const surfaceElevated = Color(0xFF0F1E38);
  static const surfaceBorder   = Color(0xFF1B304E);

  // ── Accent (emerald green) ────────────────────────────────────────────────
  static const accent      = Color(0xFF00C896);
  static const accentLight = Color(0xFF33D9AA);
  static const accentDim   = Color(0x1A00C896); // ~10 % alpha

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const success    = Color(0xFF22C55E);
  static const successDim = Color(0x2022C55E);
  static const warning    = Color(0xFFF59E0B);
  static const warningDim = Color(0x20F59E0B);
  static const error      = Color(0xFFEF4444);
  static const errorDim   = Color(0x20EF4444);
  static const info       = Color(0xFF60A5FA);
  static const infoDim    = Color(0x2060A5FA);

  // ── Status ────────────────────────────────────────────────────────────────
  static const statusCreated    = Color(0xFF94A3B8);
  static const statusAccepted   = Color(0xFF60A5FA);
  static const statusOnTheWay   = Color(0xFFF59E0B);
  static const statusInProgress = Color(0xFF00C896);
  static const statusCompleted  = Color(0xFF22C55E);
  static const statusCancelled  = Color(0xFFEF4444);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFE8F0FE);
  static const textSecondary = Color(0xFF7B9AB8);
  static const textMuted     = Color(0xFF3A5270);

  // ── Express ───────────────────────────────────────────────────────────────
  static const express    = Color(0xFFFF7043);
  static const expressDim = Color(0x20FF7043);

  // ── CTA gradient (navy → emerald) ─────────────────────────────────────────
  static const gradientStart = Color(0xFF1E4785);
  static const gradientEnd   = Color(0xFF00C896);
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
        secondary: RilyColors.info,
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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RilyColors.surfaceElevated,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RilyColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RilyColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RilyColors.accent, width: 1.5),
        ),
        labelStyle: const TextStyle(
            color: RilyColors.textSecondary, fontSize: 14),
        hintStyle:
            const TextStyle(color: RilyColors.textMuted, fontSize: 14),
        floatingLabelStyle:
            const TextStyle(color: RilyColors.accent, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RilyColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RilyColors.accent,
          side: const BorderSide(color: RilyColors.surfaceBorder),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? RilyColors.accent
                : RilyColors.textMuted),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? RilyColors.accentDim
                : RilyColors.surfaceBorder),
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: RilyColors.accent,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: RilyColors.accent,
        unselectedLabelColor: RilyColors.textSecondary,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        dividerColor: RilyColors.surfaceBorder,
      ),
      dividerTheme: const DividerThemeData(
        color: RilyColors.surfaceBorder,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: RilyColors.surfaceElevated,
        contentTextStyle: const TextStyle(color: RilyColors.textPrimary),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
