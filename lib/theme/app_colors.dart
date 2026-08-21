import 'package:flutter/material.dart';

/// All colors used across ChillBreak, matched from the Figma design.
/// Keep every color reference in the app pointing here — if you want to
/// re-theme later, you only edit this one file.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0D0B1E);
  static const Color cardBackground = Color(0xFF1C1733);
  static const Color cardBorder = Color(0x14FFFFFF); // white @ 8% opacity

  // Accents
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleDeep = Color(0xFF6D28D9);
  static const Color teal = Color(0xFF2DD4BF);
  static const Color orange = Color(0xFFFF8C42);
  static const Color gold = Color(0xFFFBBF24);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA79FC4);
  static const Color textMuted = Color(0xFF6B6485);

  static const LinearGradient purpleTealGradient = LinearGradient(
    colors: [purple, teal],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
