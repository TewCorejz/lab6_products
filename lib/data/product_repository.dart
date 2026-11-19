import '../models/product.dart';
import '../models/product_category.dart';
import 'favorites_storage.dart';
import 'product_api_client.dart';

class ProductRepository {
  final ProductApiClient _api;
  final FavoritesStorage _favoritesStorage;

  List<Product>? _cachedProducts;
  List<ProductCategory>? _cachedCategories;

  ProductRepository({
    ProductApiClient? api,
    FavoritesStorage? favoritesStorage,
  })  : _api = api ?? ProductApiClient(),
        _favoritesStorage = favoritesStorage ?? FavoritesStorage();

  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    final cached = _cachedProducts;
    if (!forceRefresh && cached != null) return cached;
    final products = await _api.fetchProducts();
    _cachedProducts = products;
    return products;
  }

  Future<List<ProductCategory>> getCategories({
    bool forceRefresh = false,
  }) async {
    final cached = _cachedCategories;
    if (!forceRefresh && cached != null) return cached;
    final categories = await _api.fetchCategories();
    _cachedCategories = categories;
    return categories;
  }

  Future<Set<int>> getFavoriteIds() => _favoritesStorage.load();

  Future<void> saveFavoriteIds(Set<int> ids) => _favoritesStorage.save(ids);
}