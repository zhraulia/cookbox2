import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:nama_project/models/item.dart';
import 'package:nama_project/providers/cart_provider.dart';
import 'package:nama_project/providers/order_provider.dart';
import 'package:nama_project/routes/app_routes.dart';
import 'package:nama_project/screens/cart_checkout_screen.dart';

// Menguji state keranjang dan alur konfirmasi tanpa backend.
const _testItem = Item(
  id: 'cart-test-item',
  title: 'Paket Ayam',
  subtitle: 'Paket masak',
  description: 'Paket ayam untuk diuji.',
  merchantName: 'Dapur Uji',
  category: 'Paket Masak',
  price: 18000,
);

// Item dari UMKM lain, dipakai untuk menguji pengelompokan per UMKM.
const _otherItem = Item(
  id: 'cart-test-item-2',
  title: 'Sayur Segar',
  subtitle: 'Segar',
  description: 'Sayur untuk diuji.',
  merchantName: 'Toko Lain',
  category: 'Segar',
  price: 8000,
);

// Menjalankan alur checkout: pilih Ambil Sendiri (tanpa ongkir dan tanpa
// syarat lokasi), pilih QRIS, lalu tekan konfirmasi.
Future<void> _checkoutPickupWithQris(
  WidgetTester tester,
  CartProvider cart,
  String merchantName,
) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>.value(value: cart),
        ChangeNotifierProvider<OrderProvider>.value(value: OrderProvider()),
      ],
      child: MaterialApp(
        home: CartCheckoutScreen(merchantName: merchantName),
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onUnknownRoute: AppRoutes.onUnknownRoute,
      ),
    ),
  );

  await tester.tap(find.text('Ambil Sendiri'));
  await tester.pumpAndSettle();

  await tester.scrollUntilVisible(
    find.text('QRIS/Saldo Digital'),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('QRIS/Saldo Digital'));
  await tester.pump();
  await tester.tap(find.text('Konfirmasi Pesanan (Rp 18.000)'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  // Selesaikan timer simulasi OrderProvider (10 detik + 15 detik) agar
  // tidak ada timer fake yang tertinggal saat test berakhir.
  await tester.pump(const Duration(seconds: 10));
  await tester.pump(const Duration(seconds: 15));
  await tester.pumpAndSettle();
}

void main() {
  test('CartProvider adds, changes, and removes quantities', () {
    final cart = CartProvider();

    cart.addItem(_testItem);
    cart.addItem(_testItem);
    expect(cart.totalQuantity, 2);
    expect(cart.subtotalPrice, 36000);
    expect(() => cart.items.clear(), throwsUnsupportedError);

    cart.decreaseQuantity(_testItem.id);
    cart.decreaseQuantity(_testItem.id);
    expect(cart.totalQuantity, 1);

    cart.increaseQuantity(_testItem.id);
    expect(cart.totalQuantity, 2);
    cart.removeItem(_testItem.id);
    expect(cart.items, isEmpty);
  });

  test('clearMerchant hanya menghapus item milik satu UMKM', () {
    final cart = CartProvider()
      ..addItem(_testItem)
      ..addItem(_otherItem);

    expect(cart.itemsFor('Dapur Uji').length, 1);
    expect(cart.subtotalFor('Toko Lain'), 8000);

    cart.clearMerchant('Dapur Uji');

    expect(cart.itemsFor('Dapur Uji'), isEmpty);
    expect(cart.itemsFor('Toko Lain').length, 1);
  });

  testWidgets('checkout confirms an order and clears the cart', (tester) async {
    final cart = CartProvider()..addItem(_testItem);

    await _checkoutPickupWithQris(tester, cart, 'Dapur Uji');

    expect(find.text('Pesanan Berhasil Dibuat!'), findsOneWidget);
    expect(find.text('QRIS/Saldo Digital'), findsOneWidget);
    expect(find.text('Rp 18.000'), findsWidgets);
    expect(cart.items, isEmpty);
  });

  testWidgets('checkout hanya menghapus item UMKM yang dicheckout', (
    tester,
  ) async {
    final cart = CartProvider()
      ..addItem(_testItem)
      ..addItem(_otherItem);

    await _checkoutPickupWithQris(tester, cart, 'Dapur Uji');

    expect(find.text('Pesanan Berhasil Dibuat!'), findsOneWidget);
    // Item UMKM yang dicheckout hilang, item UMKM lain tetap di keranjang.
    expect(cart.itemsFor('Dapur Uji'), isEmpty);
    expect(cart.itemsFor('Toko Lain').length, 1);
  });

  testWidgets('empty cart shows empty view without checkout form', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartProvider(),
        child: const MaterialApp(
          home: CartCheckoutScreen(merchantName: 'Dapur Uji'),
        ),
      ),
    );

    expect(
      find.text('Tidak ada item dari Dapur Uji di keranjang'),
      findsOneWidget,
    );
    expect(find.text('Pilihan Pengantaran'), findsNothing);
    expect(find.textContaining('Konfirmasi Pesanan'), findsNothing);
  });
}
