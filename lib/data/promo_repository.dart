import '../models/promo_preference.dart';
import '../models/umkm.dart';
import '../models/umkm_promo.dart';

/// Data layer promo. Masih dummy dan akan diganti data dari API.
class PromoRepository {
  static const List<UmkmPromo> _promos = [
    UmkmPromo(
      id: 'promo-1',
      umkmId: 'umkm-1',
      type: PromoPreference.discount,
      title: 'Diskon paket masak 25%',
      discountPercent: 25,
    ),
    UmkmPromo(
      id: 'promo-2',
      umkmId: 'umkm-1',
      type: 'Produk Baru',
      title: 'Paket bumbu rendang kini tersedia',
    ),
    UmkmPromo(
      id: 'promo-3',
      umkmId: 'umkm-2',
      type: PromoPreference.discount,
      title: 'Diskon sayur segar 15%',
      discountPercent: 15,
    ),
    UmkmPromo(
      id: 'promo-4',
      umkmId: 'umkm-3',
      type: 'Paket Hemat',
      title: 'Paket lauk 3 hari lebih hemat',
    ),
    UmkmPromo(
      id: 'promo-5',
      umkmId: 'umkm-4',
      type: 'Paket Hemat',
      title: 'Paket anak kos mingguan',
    ),
  ];

  /// Mengambil daftar promo terbaru.
  /// Saat API tersedia, hanya isi fungsi ini yang diganti.
  Future<List<UmkmPromo>> fetchPromos() async {
    return _promos;
  }

  /// Promo yang cocok dengan UMKM yang diikuti dan pilihan promonya.
  /// Daftar promo diterima dari luar, jadi fungsi ini tidak peduli
  /// datanya dari dummy atau dari API. Fungsi murni, mudah diuji.
  List<PromoMatch> findMatching(List<Umkm> umkmList, List<UmkmPromo> promos) {
    final matches = <PromoMatch>[];
    for (final umkm in umkmList) {
      final preference = umkm.promo;
      if (preference == null) continue; // UMKM belum diikuti
      for (final promo in promos) {
        if (promo.umkmId == umkm.id && _isWanted(promo, preference)) {
          matches.add(PromoMatch(umkm: umkm, promo: promo));
        }
      }
    }
    return matches;
  }

  /// Promo diinginkan jika jenisnya dipilih, dan khusus Diskon,
  /// persentasenya memenuhi minimal diskon yang diisi pengguna.
  bool _isWanted(UmkmPromo promo, PromoPreference preference) {
    if (!preference.types.contains(promo.type)) return false;

    if (promo.type == PromoPreference.discount) {
      final minDiscount = preference.minDiscount;
      final percent = promo.discountPercent;
      if (minDiscount != null && (percent == null || percent < minDiscount)) {
        return false;
      }
    }
    return true;
  }
}

