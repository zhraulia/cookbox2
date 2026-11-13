import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/item.dart';

// State keranjang lintas-screen mengikuti pola FavoritesProvider.
class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => List.unmodifiable(_items.values);

  /// Mengelompokkan item keranjang per UMKM berdasarkan [Item.merchantName].
  /// Urutan kemunculan dipertahankan dan map maupun list di dalamnya tidak bisa diubah dari luar.
  Map<String, List<CartItem>> get itemsByMerchant {
    final Map<String, List<CartItem>> grouped = {};
    for (final cartItem in _items.values) {
      final merchant = cartItem.item.merchantName;
      grouped.putIfAbsent(merchant, () => <CartItem>[]).add(cartItem);
    }
    final unmodifiableMap = grouped.map(
      (merchant, list) => MapEntry(merchant, List<CartItem>.unmodifiable(list)),
    );
    return Map.unmodifiable(unmodifiableMap);
  }

  int get totalQuantity =>
      _items.values.fold(0, (total, cartItem) => total + cartItem.quantity);

  int get subtotalPrice =>
      _items.values.fold(0, (total, cartItem) => total + cartItem.subtotal);

  /// Menghitung subtotal belanjaan untuk satu UMKM tertentu.
  int subtotalFor(String merchantName) {
    return _items.values
        .where((cartItem) => cartItem.item.merchantName == merchantName)
        .fold(0, (total, cartItem) => total + cartItem.subtotal);
  }

  /// Mengambil daftar item keranjang khusus untuk satu UMKM tertentu.
  List<CartItem> itemsFor(String merchantName) {
    return List.unmodifiable(
      _items.values.where(
        (cartItem) => cartItem.item.merchantName == merchantName,
      ),
    );
  }

  /// Menghapus seluruh item milik UMKM tertentu dari keranjang belanja.
  /// Memanggil notifyListeners() hanya jika ada item yang terhapus.
  void clearMerchant(String merchantName) {
    final keysToRemove = _items.entries
        .where((entry) => entry.value.item.merchantName == merchantName)
        .map((entry) => entry.key)
        .toList();

    if (keysToRemove.isEmpty) return;

    for (final key in keysToRemove) {
      _items.remove(key);
    }
    notifyListeners();
  }

  void addItem(Item item) {
    final cartItem = _items[item.id];
    _items[item.id] = CartItem(
      item: item,
      quantity: (cartItem?.quantity ?? 0) + 1,
    );
    notifyListeners();
  }

  void increaseQuantity(String itemId) {
    final cartItem = _items[itemId];
    if (cartItem == null) return;

    _items[itemId] = CartItem(
      item: cartItem.item,
      quantity: cartItem.quantity + 1,
    );
    notifyListeners();
  }

  void decreaseQuantity(String itemId) {
    final cartItem = _items[itemId];
    if (cartItem == null || cartItem.quantity <= 1) return;

    _items[itemId] = CartItem(
      item: cartItem.item,
      quantity: cartItem.quantity - 1,
    );
    notifyListeners();
  }

  void removeItem(String itemId) {
    if (_items.remove(itemId) != null) {
      notifyListeners();
    }
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
