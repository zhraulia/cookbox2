import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/data/umkm_repository.dart';
import 'package:nama_project/models/promo_preference.dart';
import 'package:nama_project/models/umkm.dart';
import 'package:nama_project/utils/distance_formatter.dart';

void main() {
  group('FR-M4-04: jarak UMKM', () {
    test('withPromo mempertahankan koordinat dan menandai diikuti', () {
      const umkm = Umkm(
        id: 'uji',
        name: 'UMKM Uji',
        description: 'Data uji',
        category: 'Segar',
        rating: 4.5,
        latitude: -0.9,
        longitude: 100.4,
      );

      final updated = umkm.withPromo(
        const PromoPreference(types: [PromoPreference.discount], minDiscount: 20),
      );

      expect(updated.latitude, -0.9);
      expect(updated.longitude, 100.4);
      expect(updated.isFollowing, isTrue);
      expect(umkm.isFollowing, isFalse);
    });

    test('semua UMKM dummy memiliki koordinat', () async {
      final list = await UmkmRepository().fetchUmkm();
      for (final umkm in list) {
        expect(umkm.latitude, isNotNull, reason: umkm.name);
        expect(umkm.longitude, isNotNull, reason: umkm.name);
      }
    });

    test('formatDistance menampilkan meter di bawah 1 km dan km di atasnya', () {
      expect(formatDistance(0), '0 m');
      expect(formatDistance(849.6), '850 m');
      expect(formatDistance(1000), '1,0 km');
      expect(formatDistance(2449), '2,4 km');
    });
  });
}

