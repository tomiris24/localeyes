import 'package:flutter/material.dart';

/// How LocalEyes talks about what the store sells.
///
/// The API ships supermarket categories (`men's clothing`, `jewelery`), which
/// mean nothing to someone packing for a tour. They are folded here into the
/// three kinds of kit the app actually talks about, so the feed reads like the
/// rest of LocalEyes instead of like a shop catalogue.
class GearCategory {
  const GearCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  static const GearCategory wear = GearCategory(
    'Wear',
    Icons.checkroom_rounded,
  );
  static const GearCategory tech = GearCategory('Tech', Icons.devices_rounded);
  static const GearCategory extras = GearCategory(
    'Extras',
    Icons.auto_awesome_rounded,
  );
  static const GearCategory other = GearCategory(
    'Gear',
    Icons.backpack_rounded,
  );

  /// The filter row, in the order it is drawn.
  static const List<GearCategory> filters = <GearCategory>[wear, tech, extras];

  static GearCategory of(String apiCategory) =>
      switch (apiCategory.toLowerCase()) {
        "men's clothing" || "women's clothing" => wear,
        'electronics' => tech,
        'jewelery' || 'jewellery' => extras,
        _ => other,
      };
}
