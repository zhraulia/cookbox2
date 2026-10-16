import '../models/item.dart';

/// Sumber data sementara (dummy). Nanti bisa diganti dengan API/database.
class ItemRepository {
  // Ganti isi data dummy ini sesuai aplikasi kelompok
  static const List<Item> _items = [
    Item(
      id: '1',
      title: 'Ayam Geprek Sambal Korek',
      subtitle: 'Ayam, sambal korek, nasi',
      description: 'Paket ayam geprek dengan sambal korek.',
      merchantName: 'Dapur Bu Tini',
      category: 'Paket Masak',
      imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=85',
      price: 18000,
      ingredients: ['Ayam', 'Cabai rawit', 'Bawang putih', 'Nasi'],
      cookingDuration: '25 menit',
      recipeSteps: [
        'Goreng ayam hingga matang dan berwarna keemasan.',
        'Ulek cabai rawit dan bawang putih, lalu siram sedikit minyak panas.',
        'Geprek ayam di atas sambal dan sajikan bersama nasi.',
      ],
    ),
    Item(
      id: '2',
      title: 'Cah Kangkung Terasi',
      subtitle: 'Kangkung segar, bumbu terasi',
      description: 'Sayur segar siap dimasak.',
      merchantName: 'Pasar Segar Bu Sari',
      category: 'Segar',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=85',
      price: 8500,
      ingredients: ['Kangkung', 'Bumbu terasi', 'Bawang merah', 'Cabai'],
      cookingDuration: '18 menit',
      recipeSteps: [
        'Tumis bawang merah, cabai, dan bumbu terasi hingga harum.',
        'Masukkan kangkung dan aduk hingga layu.',
        'Tambahkan sedikit air, masak hingga matang, lalu sajikan.',
      ],
    ),
    Item(
      id: '3',
      title: 'Sup Telur Bakso Gurih',
      subtitle: 'Telur, bakso, sayuran',
      description: 'Lauk praktis untuk makan sehari-hari.',
      merchantName: 'Kantin Mbak Sari',
      category: 'Lauk Instan',
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=900&q=85',
      price: 12000,
      ingredients: ['Telur', 'Bakso sapi', 'Wortel', 'Daun bawang'],
      cookingDuration: '30 menit',
      recipeSteps: [
        'Didihkan air dan masukkan wortel hingga mulai lunak.',
        'Tambahkan bakso dan bumbu, lalu masak hingga mendidih.',
        'Masukkan telur dan daun bawang, aduk perlahan hingga matang.',
      ],
    ),
    Item(
      id: '4',
      title: 'Tumis Tempe Orek',
      subtitle: 'Tempe, kecap, bumbu pilihan',
      description: 'Menu hemat dengan bahan yang sudah ditakar.',
      merchantName: 'Dapur Hemat Kampus',
      category: 'Hemat Kos',
      imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=85',
      price: 9500,
      ingredients: ['Tempe', 'Kecap manis', 'Bawang merah', 'Cabai'],
      cookingDuration: '20 menit',
      recipeSteps: [
        'Potong tempe kecil-kecil, lalu goreng hingga setengah kering.',
        'Tumis bawang merah dan cabai hingga harum.',
        'Masukkan tempe dan kecap, aduk hingga bumbu meresap.',
      ],
    ),
  ];

  /// Mengambil daftar item.
  Future<List<Item>> fetchItems() async {
    await Future.delayed(
      const Duration(seconds: 2),
    ); // simulasi waktu tunggu server
    return _items;
  }
}
