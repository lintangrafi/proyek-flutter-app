import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final ApiService apiService;
  ProductProvider({required this.apiService});

  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> loadProductsForVendor(int vendorId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Coba gunakan API dengan filter vendor_id
      _products = await apiService.getProductsByVendor(vendorId);

      // Jika tidak ada produk yang ditemukan dengan filter API, gunakan filter lokal
      if (_products.isEmpty) {
        print(
          'Tidak ada produk ditemukan dengan API filter, mencoba filter lokal',
        );

        // Ambil semua produk
        final allProducts = await apiService.fetchProducts();

        // Filter produk berdasarkan vendor_id
        _products =
            allProducts
                .where((product) => product.vendorId == vendorId)
                .toList();
        print(
          'Filter lokal menemukan ${_products.length} produk untuk vendor $vendorId',
        );
      }
    } catch (error) {
      print('Error loadProductsForVendor: $error');

      // Jika API call gagal, gunakan filter lokal
      try {
        print('Mencoba filter lokal setelah error API');
        final allProducts = await apiService.fetchProducts();
        _products =
            allProducts
                .where((product) => product.vendorId == vendorId)
                .toList();
        print(
          'Filter lokal setelah error menemukan ${_products.length} produk',
        );
      } catch (e) {
        print('Error filter lokal: $e');
        _products = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await apiService.fetchProducts();
    } catch (error) {
      print('Error loadAllProducts: $error');
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProducts() {
    if (_products.isNotEmpty) {
      _products = [];
      notifyListeners();
    }
  }

  Product getById(int id) {
    return _products.firstWhere(
      (prod) => prod.id == id,
      orElse: () => throw Exception('Product with ID $id not found'),
    );
  }
}
