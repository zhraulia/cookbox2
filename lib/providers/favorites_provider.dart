import 'package:flutter/foundation.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  bool isFavorite(String itemId) => _favoriteIds.contains(itemId);

  void toggle(String itemId) {
    if (!_favoriteIds.add(itemId)) {
      _favoriteIds.remove(itemId);
    }
    notifyListeners();
  }
}
