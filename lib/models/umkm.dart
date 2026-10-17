import 'promo_preference.dart';

/// Data satu UMKM mitra.
class Umkm {
  final String id;
  final String name;
  final String description;
  final String category;
  final double rating;
  final String? address;
  final String? phoneNumber;
  final String? imageUrl;

  /// Pilihan promo pengguna. null berarti pengguna belum mengikuti UMKM ini.
  final PromoPreference? promo;

  const Umkm({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.rating,
    this.address,
    this.phoneNumber,
    this.imageUrl,
    this.promo,
  });

  /// Status ikuti diturunkan dari promo, bukan disimpan terpisah.
  /// Dengan begitu status ikuti dan pilihan promo tidak mungkin tidak sinkron.
  bool get isFollowing => promo != null;

  /// Membuat salinan UMKM dengan pilihan promo baru (atau null untuk
  /// berhenti mengikuti). Dibuat method sendiri, bukan copyWith, karena pada
  /// copyWith nilai null ambigu: "tidak diubah" atau "dihapus".
  Umkm withPromo(PromoPreference? newPromo) {
    return Umkm(
      id: id,
      name: name,
      description: description,
      category: category,
      rating: rating,
      address: address,
      phoneNumber: phoneNumber,
      imageUrl: imageUrl,
      promo: newPromo,
    );
  }
}
