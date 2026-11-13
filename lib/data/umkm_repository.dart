import '../models/umkm.dart';
import '../models/promo_preference.dart';

/// Sumber data UMKM sementara (dummy, disimpan di memori).
/// Nanti isinya diganti pemanggilan API, layar tidak perlu diubah.
class UmkmRepository {
  // static: satu daftar dipakai bersama semua layar, jadi status "ikuti"
  // tidak hilang saat layar dibuka ulang. Pola yang sama dengan ItemRepository.
  // Nama UMKM sengaja sama dengan Item.merchantName agar bisa dicocokkan.
  // Alamat, nomor telepon, dan rating di bawah hanya contoh.
  static final List<Umkm> _umkmList = [
    const Umkm(
      id: 'umkm-1',
      name: 'Dapur Bu Tini',
      description: 'Paket masak rumahan dengan bumbu yang sudah ditakar.',
      category: 'Paket Masak',
      rating: 4.9,
      address: 'Jl. Limau Manis No. 12, Padang',
      phoneNumber: '+6281200000001',
      // Koordinat dummy perkiraan lokasi UMKM
      latitude: -0.9150,
      longitude: 100.4590,
    ),
    const Umkm(
      id: 'umkm-2',
      name: 'Pasar Segar Bu Sari',
      description: 'Sayur dan bahan segar dipilih setiap hari.',
      category: 'Segar',
      rating: 4.8,
      address: 'Jl. Pasar Raya No. 5, Padang',
      phoneNumber: '+6281200000002',
      // Koordinat dummy perkiraan lokasi UMKM
      latitude: -0.9500,
      longitude: 100.3600,
    ),
    const Umkm(
      id: 'umkm-3',
      name: 'Kantin Mbak Sari',
      description: 'Lauk instan praktis untuk makan sehari-hari.',
      category: 'Lauk Instan',
      rating: 4.9,
      address: 'Jl. Kampus Unand, Padang',
      phoneNumber: '+6281200000003',
      // Koordinat dummy perkiraan lokasi UMKM
      latitude: -0.9145,
      longitude: 100.4610,
    ),
    const Umkm(
      id: 'umkm-4',
      name: 'Dapur Hemat Kampus',
      description: 'Menu hemat untuk anak kos dengan bahan sudah ditakar.',
      category: 'Hemat Kos',
      rating: 4.7,
      address: 'Jl. Limau Manis Selatan, Padang',
      phoneNumber: '+6281200000004',
      // Koordinat dummy perkiraan lokasi UMKM
      latitude: -0.9250,
      longitude: 100.4560,
    ),
    const Umkm(
      id: 'umkm-5',
      name: 'Dapur Barokah Kampus',
      description: 'Spesialis paket bumbu siap olah dan olahan Nusantara.',
      category: 'Paket Masak',
      rating: 4.9,
      address: 'Jl. Dr. Hamka, Padang',
      phoneNumber: '+6281200000005',
      // Koordinat dummy perkiraan lokasi UMKM
      latitude: -0.9005,
      longitude: 100.3490,
    ),
  ];

  /// Mengambil daftar UMKM.
  /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
  Future<List<Umkm>> fetchUmkm({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 1)); // simulasi waktu tunggu
    if (simulateError) {
      throw Exception('Gagal memuat data UMKM. Periksa koneksi internet.');
    }
    // Salinan yang tidak bisa diubah dari luar.
    return List.unmodifiable(_umkmList);
  }

  /// Create atau Update: menyimpan pilihan promo.
  /// Kalau UMKM belum diikuti, otomatis menjadi diikuti.
  Umkm setPromo(String umkmId, PromoPreference promo) {
    return _update(umkmId, (umkm) => umkm.withPromo(promo));
  }

  /// Delete: berhenti mengikuti UMKM (pilihan promo dihapus).
  Umkm clearPromo(String umkmId) {
    return _update(umkmId, (umkm) => umkm.withPromo(null));
  }

  /// Menggantikan satu UMKM di daftar dengan hasil perubahan,
  /// lalu mengembalikan UMKM yang sudah diperbarui.
  Umkm _update(String umkmId, Umkm Function(Umkm) change) {
    final index = _umkmList.indexWhere((umkm) => umkm.id == umkmId);
    if (index == -1) {
      throw ArgumentError.value(umkmId, 'umkmId', 'UMKM tidak ditemukan.');
    }

    final updated = change(_umkmList[index]);
    _umkmList[index] = updated;
    return updated;
  }

  /// Mencari UMKM berdasarkan nama toko, null kalau tidak ditemukan.
  /// Dipakai modul lain yang hanya punya nama toko (Item.merchantName).
  static Umkm? findByName(String name) {
    for (final umkm in _umkmList) {
      if (umkm.name.toLowerCase() == name.toLowerCase()) return umkm;
    }
    return null;
  }

  /// Mencari UMKM berdasarkan id, null kalau tidak ditemukan.
  static Umkm? findById(String id) {
    for (final umkm in _umkmList) {
      if (umkm.id == id) return umkm;
    }
    return null;
  }
}
