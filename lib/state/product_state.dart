import 'package:flutter/foundation.dart';

import '../data/product_api_client.dart';
import '../data/product_repository.dart';
import '../models/product.dart';
import '../models/product_category.dart';

enum LoadStatus { initial, loading, success, error }

enum SortOption {
  none('По умолчанию'),
  priceAsc('Цена: по возрастанию'),
  priceDesc('Цена: по убыванию'),
  ratingDesc('Рейтинг: сначала высокий'),
  titleAsc('Название: A–Z');

  const SortOption(this.label);

  final String label;
}

class ProductState extends ChangeNotifier {
  ProductState(this._repository);

  final ProductRepository _repository;

  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;
  List<Product> _allProducts = const [];
  List<Product> _visibleProducts = const [];
  List<ProductCategory> _categories = const [];
  String _query = '';
  String? _selectedCategory;
  SortOption _sort = SortOption.none;
  Set<int> _favoriteIds = const {};

  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<Product> get visibleProducts => _visibleProducts;
  List<ProductCategory> get categories => _categories;
  String get query => _query;
  String? get selectedCategory => _selectedCategory;
  SortOption get sort => _sort;

  bool get isLoading => _status == LoadStatus.loading;
  bool get hasError => _status == LoadStatus.error;
  bool get isEmptyResult =>
      _status == LoadStatus.success && _visibleProducts.isEmpty;
  bool get hasActiveFilters => _query.isNotEmpty || _selectedCategory != null;

  List<Product> get favoriteProducts => List.unmodifiable(
        _allProducts.where((p) => _favoriteIds.contains(p.id)),
      );

  Future<void> init() async {
    await loadFavorites();
    await loadProducts();
  }

  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (_status == LoadStatus.loading) return;
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final products =
          await _repository.getProducts(forceRefresh: forceRefresh);
      final categories =
          await _repository.getCategories(forceRefresh: forceRefresh);
      _allProducts = List.unmodifiable(products);
      _categories = List.unmodifiable(categories);
      _status = LoadStatus.success;
      _updateVisible();
    } on ApiException catch (e) {
      _status = LoadStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      _status = LoadStatus.error;
      _errorMessage = 'Что-то пошло не так';
    }
    notifyListeners();
  }

  Future<void> retry() => loadProducts(forceRefresh: true);

  void setQuery(String value) {
    final trimmed = value.trim();
    if (trimmed == _query) return;
    _query = trimmed;
    _updateVisible();
    notifyListeners();
  }

  void selectCategory(String? slug) {
    _selectedCategory = _selectedCategory == slug ? null : slug;
    _updateVisible();
    notifyListeners();
  }

  void setSort(SortOption option) {
    if (option == _sort) return;
    _sort = option;
    _updateVisible();
    notifyListeners();
  }

  void resetFilters() {
    _query = '';
    _selectedCategory = null;
    _updateVisible();
    notifyListeners();
  }

  String categoryName(String slug) {
    for (final c in _categories) {
      if (c.slug == slug) return c.name;
    }
    return slug;
  }

  bool isFavorite(int productId) => _favoriteIds.contains(productId);

  Future<void> loadFavorites() async {
    try {
      _favoriteIds = await _repository.getFavoriteIds();
    } catch (_) {
      _favoriteIds = const {};
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(Product product) async {
    final updated = Set<int>.of(_favoriteIds);
    if (!updated.remove(product.id)) {
      updated.add(product.id);
    }
    _favoriteIds = updated;
    notifyListeners();
    await _repository.saveFavoriteIds(updated);
  }

  void _updateVisible() {
    final q = _query.toLowerCase();
    final result = _allProducts.where((p) {
      final matchesCategory =
          _selectedCategory == null || p.category == _selectedCategory;
      final matchesQuery = q.isEmpty || p.title.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();

    final Comparator<Product>? comparator = switch (_sort) {
      SortOption.none => null,
      SortOption.priceAsc => (a, b) => a.price.compareTo(b.price),
      SortOption.priceDesc => (a, b) => b.price.compareTo(a.price),
      SortOption.ratingDesc => (a, b) => b.rating.compareTo(a.rating),
      SortOption.titleAsc => (a, b) =>
          a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    };
    if (comparator != null) result.sort(comparator);

    _visibleProducts = List.unmodifiable(result);
  }
}