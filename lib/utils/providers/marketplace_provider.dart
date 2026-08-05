import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../constants/constants.dart';
import '../models/marketplace_item.dart';

class MarketplaceProvider extends ChangeNotifier {
  List<MarketplaceItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<MarketplaceItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Published goods grouped by category, for the marketplace screen.
  Map<String, List<MarketplaceItem>> get itemsByCategory {
    final grouped = <String, List<MarketplaceItem>>{};
    for (final item in _items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  Future<void> fetchPublishedGoods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.get(Constants.MARKETPLACE_PUBLISHED_GOODS);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        _items = (data['goods'] as List)
            .map((json) => MarketplaceItem.fromJson(json))
            .toList();
      } else {
        _error = data['message'] ?? 'Could not load marketplace';
      }
    } catch (e) {
      log(e.toString(), name: 'MarketplaceProvider.fetchPublishedGoods');
      _error = 'Could not load marketplace. Check your connection.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add goods and publish them to the estate in one step. Returns null on
  /// success or an error message on failure.
  Future<String?> addGoods({
    required String name,
    required String description,
    required String quantity,
    required String offer,
    required String category,
  }) async {
    try {
      final response = await ApiClient.post(
        Constants.MARKETPLACE_ADD_GOODS,
        body: {
          'goods_name': name,
          'goods_description': description,
          'goods_quantity': quantity,
          'any_offer': offer,
          'category': category,
        },
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        await fetchPublishedGoods();
        return null;
      }
      return data['message'] ?? 'Could not add goods';
    } catch (e) {
      log(e.toString(), name: 'MarketplaceProvider.addGoods');
      return 'Could not add goods. Check your connection.';
    }
  }
}
