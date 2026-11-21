import 'json.dart';

/// One row of the catalog.
///
/// Deliberately lighter than [Tour]: the catalog has to be able to make a new
/// item on every pull-to-refresh, and a full tour would need a guide, a route
/// and reviews to go with it.
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.title,
    required this.category,
    required this.rating,
    required this.price,
    this.isNew = false,
  });

  factory CatalogItem.fromJson(Map<String, dynamic> json) => CatalogItem(
    id: asString(json['id']),
    title: asString(json['title'], 'Untitled'),
    category: asString(json['category']),
    rating: asDouble(json['rating']),
    price: asDouble(json['price']),
    isNew: asBool(json['isNew']),
  );

  final String id;
  final String title;
  final String category;
  final double rating;
  final double price;

  /// Set on the items that pull-to-refresh adds, so the new row is visible.
  final bool isNew;

  String get priceLabel => '\$${price.toStringAsFixed(0)}';
  String get ratingLabel => rating.toStringAsFixed(1);
}
