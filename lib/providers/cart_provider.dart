import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/item.dart';

// State keranjang lintas-screen mengikuti pola FavoritesProvider.
class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => List.unmodifiable(_items.values);

  int get totalQuantity =>
      _items.values.fold(0, (total, cartItem) => total + cartItem.quantity);

  int get subtotalPrice =>
      _items.values.fold(0, (total, cartItem) => total + cartItem.subtotal);

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
