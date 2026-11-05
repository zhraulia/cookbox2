import 'package:flutter/material.dart';

/// Model representasi data butir Pertanyaan yang Sering Diajukan (FAQ).
class FaqItem {
  final String id;
  final String question;
  final String answer;
  final String category;
  final IconData icon;
  final Color color;

  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.icon = Icons.help_outline_rounded,
    this.color = Colors.orange,
  });
}
