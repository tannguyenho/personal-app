// GENERATED CODE - DO NOT MODIFY BY HAND.
// Sinh từ tokens.json bằng `dart run tool/generate.dart`.

import 'package:flutter/material.dart';

const _lightBgPrimary = _lightBrand500;
const _lightBgSecondary = Color(0xFFE5E7EB);
const _lightBrand500 = Color(0xFF4F46E5);
const _lightTextOnPrimary = Color(0xFFFFFFFF);
const _lightTextOnSecondary = Color(0xFF111827);

const _darkBgPrimary = _darkBrand500;
const _darkBgSecondary = Color(0xFF374151);
const _darkBrand500 = Color(0xFF818CF8);
const _darkTextOnPrimary = Color(0xFF0B0B12);
const _darkTextOnSecondary = Color(0xFFF9FAFB);

/// Màu ngữ nghĩa của design system. Một trường = một Figma Variable.
@immutable
class DsColors extends ThemeExtension<DsColors> {
  const DsColors({
    required this.bgPrimary,
    required this.bgSecondary,
    required this.brand500,
    required this.textOnPrimary,
    required this.textOnSecondary,
  });

  static const light = DsColors(
    bgPrimary: _lightBgPrimary,
    bgSecondary: _lightBgSecondary,
    brand500: _lightBrand500,
    textOnPrimary: _lightTextOnPrimary,
    textOnSecondary: _lightTextOnSecondary,
  );

  static const dark = DsColors(
    bgPrimary: _darkBgPrimary,
    bgSecondary: _darkBgSecondary,
    brand500: _darkBrand500,
    textOnPrimary: _darkTextOnPrimary,
    textOnSecondary: _darkTextOnSecondary,
  );

  /// `color/bg/primary`
  final Color bgPrimary;
  /// `color/bg/secondary`
  final Color bgSecondary;
  /// `color/brand/500`
  final Color brand500;
  /// `color/text/onPrimary`
  final Color textOnPrimary;
  /// `color/text/onSecondary`
  final Color textOnSecondary;

  @override
  DsColors copyWith({
    Color? bgPrimary,
    Color? bgSecondary,
    Color? brand500,
    Color? textOnPrimary,
    Color? textOnSecondary,
  }) {
    return DsColors(
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      brand500: brand500 ?? this.brand500,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      textOnSecondary: textOnSecondary ?? this.textOnSecondary,
    );
  }

  @override
  DsColors lerp(DsColors? other, double t) {
    if (other == null) return this;
    return DsColors(
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      brand500: Color.lerp(brand500, other.brand500, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      textOnSecondary: Color.lerp(textOnSecondary, other.textOnSecondary, t)!,
    );
  }
}
