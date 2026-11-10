import 'umkm.dart';

/// Satu promo yang diumumkan oleh sebuah UMKM.
class UmkmPromo {
  final String id;
  final String umkmId;

  /// Salah satu dari PromoPreference.availableTypes.
  final String type;
  final String title;

  /// Persentase diskon, hanya terisi untuk jenis Diskon.
  final int? discountPercent;

  const UmkmPromo({
    required this.id,
    required this.umkmId,
    required this.type,
    required this.title,
    this.discountPercent,
  });
}

/// Pasangan UMKM dan promonya yang cocok dengan pilihan pengguna.
class PromoMatch {
  final Umkm umkm;
  final UmkmPromo promo;

  const PromoMatch({required this.umkm, required this.promo});
}

