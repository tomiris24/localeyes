/// One product from the Fake Store API (`https://fakestoreapi.com/products`).
class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
  });

  /// Builds a product out of one decoded JSON object.
  ///
  /// Every field goes through a fallback: a public API can drop a key or send
  /// null at any time, and a single missing `title` should not take the whole
  /// feed down.
  factory Product.fromJson(Map<String, dynamic> json) {
    // `rating` is nested: {"rate": 3.9, "count": 120}.
    final Object? rating = json['rating'];
    final Map<String, dynamic> ratingJson = rating is Map<String, dynamic>
        ? rating
        : const <String, dynamic>{};

    return Product(
      id: _asInt(json['id']),
      title: _asString(json['title'], 'Untitled product'),
      price: _asDouble(json['price']),
      description: _asString(json['description'], 'No description provided.'),
      category: _asString(json['category'], 'misc'),
      imageUrl: _asString(json['image'], ''),
      rating: _asDouble(ratingJson['rate']),
      reviewCount: _asInt(ratingJson['count']),
    );
  }

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;

  /// JSON numbers arrive as `int` when they are whole (`price: 109` instead of
  /// `109.0`), so a plain `as double` cast would throw. `as num` accepts both.
  static double _asDouble(Object? value) => value is num ? value.toDouble() : 0;

  static int _asInt(Object? value) => value is num ? value.toInt() : 0;

  static String _asString(Object? value, String fallback) {
    final String text = value is String ? value.trim() : '';
    return text.isEmpty ? fallback : text;
  }

  String get priceLabel => '\$${price.toStringAsFixed(2)}';
  String get ratingLabel => rating.toStringAsFixed(1);
  String get reviewLabel => '$reviewCount reviews';

  /// What the share sheet shows and copies.
  String get deepLink => 'narxoz://store/product/$id';
}
