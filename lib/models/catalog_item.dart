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
