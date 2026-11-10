/// Mengubah jarak dalam meter menjadi teks yang mudah dibaca.
/// Contoh: 850 menjadi "850 m", 2449 menjadi "2,4 km".
String formatDistance(double meters) {
  final rounded = meters.round();
  if (rounded < 1000) return '$rounded m';
  return '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
}

