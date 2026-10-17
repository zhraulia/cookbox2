/// Pilihan promo yang dipilih pengguna saat mengikuti sebuah UMKM.
class PromoPreference {
  /// Daftar jenis promo ditulis sekali di sini supaya tidak berulang di layar.
  static const String discount = 'Diskon';
  static const List<String> availableTypes = [
    discount,
    'Produk Baru',
    'Paket Hemat',
  ];

  /// Batas minimal diskon (persen) yang boleh diisi pengguna.
  static const int minDiscountLimit = 15;
  static const int maxDiscountLimit = 80;

  final List<String> types;
  final int? minDiscount;

  const PromoPreference({required this.types, this.minDiscount});

  /// Ringkasan untuk kartu dan SnackBar, contoh: "Diskon ≥ 20%, Produk Baru".
  String get summary {
    return types
        .map((type) {
          if (type == discount && minDiscount != null) {
            return '$discount ≥ $minDiscount%';
          }
          return type;
        })
        .join(', ');
  }
}
