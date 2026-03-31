class BeautyProduct {
  final String barcode;
  final String name;
  final String brand;
  final String? imageUrl;
  final List<String> categories;

  const BeautyProduct({
    required this.barcode,
    required this.name,
    required this.brand,
    this.imageUrl,
    this.categories = const [],
  });

  factory BeautyProduct.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories_tags'] as List<dynamic>? ?? [];

    return BeautyProduct(
      barcode: json['code']?.toString() ?? '',
      name: json['product_name']?.toString().trim() ?? '',
      brand: json['brands']?.toString().trim() ?? '',
      imageUrl: json['image_front_small_url']?.toString() ??
                json['image_front_url']?.toString(),
      categories: rawCategories
          .map((c) => c.toString().replaceAll('en:', '').replaceAll('-', ' '))
          .toList(),
    );
  }
}