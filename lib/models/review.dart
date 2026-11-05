/// Model data ulasan untuk pesanan yang telah selesai.
class Review {
  final String id;
  final int rating; // Nilai bintang antara 1 sampai 5
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  /// Membuat salinan objek dengan field yang diperbarui.
  Review copyWith({
    String? id,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
