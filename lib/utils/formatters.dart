/// Kumpulan fungsi pemformatan teks yang dapat digunakan kembali di seluruh aplikasi.
class AppFormatters {
  AppFormatters._();

  /// Memformat angka integer menjadi format mata uang Rupiah.
  /// Contoh: 18000 -> "Rp 18.000"
  static String rupiah(int? amount, {String fallback = 'Harga belum tersedia'}) {
    if (amount == null) return fallback;
    final digits = amount.toString();
    final grouped = digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp $grouped';
  }
}
