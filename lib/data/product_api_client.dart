import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/product_category.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class ProductApiClient {
  static const String _baseUrl = 'https://dummyjson.com';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  ProductApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Product>> fetchProducts({int limit = 0, int skip = 0}) async {
    final data = await _get('/products', {
      'limit': '$limit',
      'skip': '$skip',
    });
    final list = (data as Map<String, dynamic>)['products'] as List<dynamic>;
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductCategory>> fetchCategories() async {
    final data = await _get('/products/categories');
    return (data as List<dynamic>).map(ProductCategory.fromJson).toList();
  }

  Future<dynamic> _get(String path, [Map<String, String>? query]) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        throw ApiException('Ошибка сервера: ${response.statusCode}');
      }
      return jsonDecode(response.body);
    } on SocketException {
      throw const ApiException('Нет подключения к интернету');
    } on TimeoutException {
      throw const ApiException('Сервер не отвечает. Попробуйте позже');
    } on http.ClientException {
      throw const ApiException('Не удалось выполнить запрос');
    } on FormatException {
      throw const ApiException('Некорректный ответ сервера');
    }
  }
}