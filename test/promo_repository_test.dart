import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/data/promo_repository.dart';
import 'package:nama_project/models/promo_preference.dart';
import 'package:nama_project/models/umkm.dart';

Umkm _umkm(String id, {PromoPreference? promo}) {
  return Umkm(
    id: id,
    name: 'UMKM Uji',
    description: 'Data uji',
    category: 'Segar',
    rating: 4.5,
    promo: promo,
  );
}

void main() {
  final repository = PromoRepository();

  test('UMKM yang belum diikuti tidak menghasilkan promo', () async {
    final promos = await repository.fetchPromos();
    final matches = repository.findMatching([_umkm('umkm-1')], promos);
    expect(matches, isEmpty);
  });

  test('hanya promo sesuai jenis dan minimal diskon yang cocok', () async {
    final promos = await repository.fetchPromos();
    final umkm = _umkm(
      'umkm-1',
      promo: const PromoPreference(
        types: [PromoPreference.discount],
        minDiscount: 20,
      ),
    );
    final matches = repository.findMatching([umkm], promos);

    expect(matches.length, 1);
    expect(matches.first.promo.id, 'promo-1');
  });

  test('diskon di bawah minimal tidak dikirim', () async {
    final promos = await repository.fetchPromos();
    final umkm = _umkm(
      'umkm-1',
      promo: const PromoPreference(
        types: [PromoPreference.discount],
        minDiscount: 30,
      ),
    );
    expect(repository.findMatching([umkm], promos), isEmpty);
  });

  test('jenis promo yang tidak dipilih tidak dikirim', () async {
    final promos = await repository.fetchPromos();
    final umkm = _umkm(
      'umkm-3',
      promo: const PromoPreference(types: ['Produk Baru']),
    );
    expect(repository.findMatching([umkm], promos), isEmpty);
  });
}

