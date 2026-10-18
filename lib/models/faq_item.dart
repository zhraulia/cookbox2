/// Model representasi data butir Pertanyaan yang Sering Diajukan (FAQ).
class FaqItem {
  final String id;
  final String question;
  final String answer;
  final String category;

  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    this.category = 'Umum',
  });
}
