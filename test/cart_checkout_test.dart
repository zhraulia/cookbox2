import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:nama_project/models/item.dart';
import 'package:nama_project/providers/cart_provider.dart';
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

  testWidgets('checkout confirms an order and clears the cart', (tester) async {
    final cart = CartProvider()..addItem(_testItem);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: cart,
        child: MaterialApp(
          home: const CartCheckoutScreen(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
          onUnknownRoute: AppRoutes.onUnknownRoute,
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('QRIS/Saldo Digital'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('QRIS/Saldo Digital'));
    await tester.pump();
    await tester.tap(find.text('Konfirmasi Pesanan (Rp 23.000)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Pesanan Berhasil Dibuat!'), findsOneWidget);
    expect(find.text('QRIS/Saldo Digital'), findsOneWidget);
    expect(find.text('Rp 23.000'), findsOneWidget);
    expect(cart.items, isEmpty);
  });

  testWidgets('empty cart shows empty view without checkout form', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartProvider(),
        child: const MaterialApp(home: CartCheckoutScreen()),
      ),
    );

    expect(find.text('Keranjang kamu masih kosong'), findsOneWidget);
    expect(find.text('Pilihan Pengantaran'), findsNothing);
    expect(find.textContaining('Konfirmasi Pesanan'), findsNothing);
  });
}
