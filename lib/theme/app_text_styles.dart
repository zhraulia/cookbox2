import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const textTheme = TextTheme(
    displaySmall: TextStyle(
      color: AppColors.ink,
      fontSize: 19,
      fontWeight: FontWeight.w800,
      height: 1.2,
    ),
    headlineSmall: TextStyle(
      color: AppColors.ink,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: TextStyle(color: AppColors.ink, fontSize: 12, height: 1.35),
    bodyMedium: TextStyle(color: AppColors.muted, fontSize: 10, height: 1.35),
    labelLarge: TextStyle(
      color: AppColors.surface,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    ),
  );
}
