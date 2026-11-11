import 'package:flutter/foundation.dart';

import '../models/promo_preference.dart';
import '../models/umkm.dart';
import '../models/umkm_promo.dart';

/// Data layer promo. Masih dummy dan akan diganti data dari API.
class PromoRepository {
  static final List<UmkmPromo> _promos = [
    UmkmPromo(
      id: 'promo-1',
      umkmId: 'umkm-1',
      type: PromoPreference.discount,
      title: 'Diskon paket masak 25%',
      discountPercent: 25,
      createdAt: DateTime(2026, 11, 9, 8, 0),
    ),
    UmkmPromo(
      id: 'promo-2',
      umkmId: 'umkm-1',
      type: 'Produk Baru',
      title: 'Paket bumbu rendang kini tersedia',
      createdAt: DateTime(2026, 11, 8, 15, 0),
    ),
    UmkmPromo(
      id: 'promo-3',
      umkmId: 'umkm-2',
      type: PromoPreference.discount,
      title: 'Diskon sayur segar 15%',
      discountPercent: 15,
      createdAt: DateTime(2026, 11, 7, 10, 0),
    ),
    UmkmPromo(
      id: 'promo-4',
      umkmId: 'umkm-3',
      type: 'Paket Hemat',
      title: 'Paket lauk 3 hari lebih hemat',
      createdAt: DateTime(2026, 11, 9, 12, 0),
    ),
    UmkmPromo(
      id: 'promo-5',
      umkmId: 'umkm-4',
      type: 'Paket Hemat',
      title: 'Paket anak kos mingguan',
      createdAt: DateTime(2026, 11, 6, 9, 0),
    ),
  ];

  /// Id promo yang sudah dibuka, urut sesuai waktu dibuka (yang terbaru dibuka
  /// ada di paling akhir). Disimpan static agar dibagi oleh semua layar,
  /// polanya sama dengan UmkmRepository.
  static final List<String> _readIds = [];

  /// Id promo yang ditutup pengguna lewat tombol silang.
  static final Set<String> _dismissedIds = {};

  bool isRead(String promoId) => _readIds.contains(promoId);

  /// Menandai promo sudah dibuka. Aman dipanggil berulang kali.
  void markAsRead(String promoId) {
    if (!_readIds.contains(promoId)) _readIds.add(promoId);
  }

  /// Menutup promo dari daftar notifikasi.
  void dismiss(String promoId) {
    _dismissedIds.add(promoId);
  }

  /// Daftar yang ditampilkan di layar notifikasi:
  /// 1) promo yang ditutup dibuang,
  /// 2) yang belum dibuka di atas, urut dari yang terbaru,
  /// 3) yang sudah dibuka di bawah, urut sesuai waktu dibuka
  ///    (yang paling akhir dibuka ada di paling bawah).
  List<PromoMatch> inboxFrom(List<PromoMatch> matches) {
    final visible = matches
        .where((match) => !_dismissedIds.contains(match.promo.id))
        .toList();

    final unread = visible.where((match) => !isRead(match.promo.id)).toList()
      ..sort((a, b) => b.promo.createdAt.compareTo(a.promo.createdAt));

    final read = visible.where((match) => isRead(match.promo.id)).toList()
      ..sort(
        (a, b) => _readIds
            .indexOf(a.promo.id)
            .compareTo(_readIds.indexOf(b.promo.id)),
      );

    return [...unread, ...read];
  }

  /// Jumlah notifikasi yang belum dibuka dan belum ditutup (untuk lencana).
  int unreadCount(List<PromoMatch> matches) {
    return matches
        .where(
          (match) =>
              !_dismissedIds.contains(match.promo.id) && !isRead(match.promo.id),
        )
        .length;
  }

  /// Hanya untuk test: mengembalikan status dibuka dan ditutup ke awal.
  @visibleForTesting
  static void resetNotificationState() {
    _readIds.clear();
    _dismissedIds.clear();
  }

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

