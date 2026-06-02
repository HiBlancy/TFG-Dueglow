import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum ProductListType {
  have('have', Icons.check_circle_outline, Colors.green),
  wishlist('wishlist', Icons.favorite_border, Colors.pink),
  used('used', Icons.history, Colors.blue);

  final String value;
  final IconData icon;
  final Color color;

  const ProductListType(this.value, this.icon, this.color);

  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case ProductListType.have:
        return l10n.productListHave;
      case ProductListType.wishlist:
        return l10n.productListWishlist;
      case ProductListType.used:
        return l10n.productListUsed;
    }
  }

  static ProductListType fromValue(String value) {
    try {
      return values.firstWhere((type) => type.value == value);
    } catch (e) {
      return have;
    }
  }

  static ProductListType fromNullable(String? value) {
    if (value == null || value.isEmpty) {
      return have;
    }
    return fromValue(value);
  }
}
