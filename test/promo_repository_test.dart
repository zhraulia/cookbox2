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

  group('urutan notifikasi', () {
    setUp(() {
      PromoRepository.resetNotificationState();
    });

    final umkm = _umkm(
      'umkm-1',
      promo: const PromoPreference(
        types: [PromoPreference.discount, 'Produk Baru'],
        minDiscount: 20,
      ),
    );

    test('belum ada yang dibuka: inboxFrom mengembalikan promo-1 lalu promo-2 (terbaru di atas), unreadCount = 2', () async {
      final promos = await repository.fetchPromos();
      final matches = repository.findMatching([umkm], promos);

      final inbox = repository.inboxFrom(matches);
      expect(inbox.map((m) => m.promo.id).toList(), ['promo-1', 'promo-2']);
      expect(repository.unreadCount(matches), 2);
    });

    test('setelah markAsRead(\'promo-1\'): urutannya promo-2 lalu promo-1 (yang dibuka turun ke bawah), unreadCount = 1', () async {
      final promos = await repository.fetchPromos();
      final matches = repository.findMatching([umkm], promos);

      repository.markAsRead('promo-1');
      final inbox = repository.inboxFrom(matches);
      expect(inbox.map((m) => m.promo.id).toList(), ['promo-2', 'promo-1']);
      expect(repository.unreadCount(matches), 1);
    });

    test('setelah markAsRead(\'promo-1\') lalu markAsRead(\'promo-2\'): urutannya promo-1 lalu promo-2 (yang paling akhir dibuka ada di paling bawah), unreadCount = 0', () async {
      final promos = await repository.fetchPromos();
      final matches = repository.findMatching([umkm], promos);

      repository.markAsRead('promo-1');
      repository.markAsRead('promo-2');
      final inbox = repository.inboxFrom(matches);
      expect(inbox.map((m) => m.promo.id).toList(), ['promo-1', 'promo-2']);
      expect(repository.unreadCount(matches), 0);
    });

    test('setelah dismiss(\'promo-2\'): inboxFrom hanya berisi promo-1, dan unreadCount = 1', () async {
      final promos = await repository.fetchPromos();
      final matches = repository.findMatching([umkm], promos);

      repository.dismiss('promo-2');
      final inbox = repository.inboxFrom(matches);
      expect(inbox.map((m) => m.promo.id).toList(), ['promo-1']);
      expect(repository.unreadCount(matches), 1);
    });

    test('markAsRead dipanggil dua kali untuk id yang sama tidak menggandakan item', () async {
      final promos = await repository.fetchPromos();
      final matches = repository.findMatching([umkm], promos);

      repository.markAsRead('promo-1');
      repository.markAsRead('promo-1');
      final inbox = repository.inboxFrom(matches);
      expect(inbox.length, 2);
      expect(inbox.map((m) => m.promo.id).toList(), ['promo-2', 'promo-1']);
    });
  });
}

