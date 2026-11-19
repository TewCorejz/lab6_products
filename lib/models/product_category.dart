class ProductCategory {
  final String slug;
  final String name;

  const ProductCategory({required this.slug, required this.name});

  factory ProductCategory.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final slug = json['slug'] as String? ?? '';
      return ProductCategory(
        slug: slug,
        name: json['name'] as String? ?? slug,
      );
    }
    final slug = json.toString();
    return ProductCategory(slug: slug, name: _prettify(slug));
  }

  static String _prettify(String slug) {
    final text = slug.replaceAll('-', ' ');
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}