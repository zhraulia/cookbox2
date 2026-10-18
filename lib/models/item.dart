import '../utils/formatters.dart';

class Item {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String merchantName;
  final String category;
  final String? imageUrl;
  final int? price;
  final List<String> ingredients;
  final String? cookingDuration;
  final List<String> recipeSteps;

  const Item({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.merchantName,
    required this.category,
    this.imageUrl,
    this.price,
    this.ingredients = const [],
    this.cookingDuration,
    this.recipeSteps = const [],
  });

  String get priceLabel => AppFormatters.rupiah(price);
}
