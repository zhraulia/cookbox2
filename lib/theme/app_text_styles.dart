import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const titleLarge = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.2,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const body = TextStyle(
    fontSize: 13,
    color: AppColors.ink,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.ink,
  );

  static const bodyMuted = TextStyle(
    fontSize: 12,
    color: AppColors.muted,
  );

  static const caption = TextStyle(
    fontSize: 11,
    color: AppColors.muted,
  );

  static const badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const buttonLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const textTheme = TextTheme(
    displaySmall: titleLarge,
    headlineSmall: titleMedium,
    titleMedium: titleSmall,
    bodyLarge: TextStyle(color: AppColors.ink, fontSize: 12, height: 1.35),
    bodyMedium: TextStyle(color: AppColors.muted, fontSize: 10, height: 1.35),
    labelLarge: TextStyle(
      color: AppColors.surface,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    ),
  );
}
