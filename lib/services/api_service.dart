import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/purchase_order.dart';
import '../models/vendor.dart';
import '../models/product.dart';
import '../models/user.dart'; // Pastikan model User sudah dibuat
import '../models/warehouse.dart'; // Pastikan model Warehouse sudah dibuat
import '../models/goods_receipt.dart';

class ApiService {
  String baseUrl = 'http://192.168.1.170:8000';
  String? token;
  User? _currentUser; // Tambahkan property untuk menyimpan user saat ini

  User? get currentUser => _currentUser; // Getter untuk user saat ini

  ApiService({required this.baseUrl, this.token});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // === AUTH ===
  // Modifikasi login untuk mengembalikan Map yang berisi token dan user info
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      token = data['token'];

      // Coba ambil user info dari respons login jika tersedia
      if (data.containsKey('user')) {
        _currentUser = User.fromJson(data['user']);
        return {'token': token, 'user': _currentUser};
      }

      // Jika tidak ada info user di respons login, coba dapatkan dari endpoint user
      try {
        final userInfo = await getUserInfo();
        return {'token': token, 'user': userInfo};
      } catch (e) {
        print('Error getting user info: $e');
        // Tetap kembalikan token meskipun gagal mendapatkan user info
        return {'token': token};
      }
    }

    // Login gagal
    return {};
  }

  // Tambahkan metode untuk mendapatkan info user
  Future<User> getUserInfo() async {
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/user'), // Sesuaikan dengan endpoint API Anda
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _currentUser = User.fromJson(data);
      return _currentUser!;
    } else {
      throw Exception('Failed to get user info: ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    if (token == null) return;
    try {
      await http.post(Uri.parse('$baseUrl/api/logout'), headers: _headers);
    } catch (e) {
      print('Error during logout: $e');
    }
    token = null;
    _currentUser = null; // Reset user saat logout
  }

  // === PURCHASE ORDERS ===
  Future<List<PurchaseOrder>> fetchPurchaseOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/purchase-orders'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => PurchaseOrder.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data Purchase Order');
    }
  }

  Future<PurchaseOrder> createPurchaseOrder(PurchaseOrder order) async {
    try {
      // Pastikan created_by diisi jika belum
      var orderData = order.toJson();
      if (!orderData.containsKey('created_by') && _currentUser != null) {
        orderData['created_by'] = _currentUser!.id;
      }

      // Log data yang dikirim
      print('Creating PO with data: ${jsonEncode(orderData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/purchase-orders'),
        headers: _headers,
        body: jsonEncode(orderData),
      );

      // Log respons
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PurchaseOrder.fromJson(responseData);
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
          // Jika gagal parse JSON
          print('Gagal parse response body: $e');
        }

        final errorMessage = errorData['message'] ?? 'Unknown server error';
        throw Exception(
          'Gagal membuat PO: $errorMessage (${response.statusCode})',
        );
      }
    } catch (e) {
      print('Exception in createPurchaseOrder: $e');
      rethrow;
    }
  }

  Future<PurchaseOrder> getPurchaseOrderById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/purchase-orders/$id'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return PurchaseOrder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal mengambil detail PO');
    }
  }

  Future<bool> updateOrderStatus(int id, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/purchase-orders/$id/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    return response.statusCode == 200;
  }

  // === VENDORS ===
  Future<List<Vendor>> fetchVendors() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/vendors'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Vendor.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data Vendor');
    }
  }

  Future<Vendor> getVendorById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/vendors/$id'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Vendor.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal mengambil detail vendor');
    }
  }

  // === PRODUCTS ===
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data Produk');
    }
  }

  Future<Product> getProductById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal mengambil detail produk');
    }
  }

  // Untuk produk berdasarkan vendor
  Future<List<Product>> getProductsByVendor(int vendorId) async {
    try {
      // Ambil semua produk dulu
      final response = await http.get(
        Uri.parse('$baseUrl/api/products'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        // Konversi semua ke model Product
        final allProducts = data.map((e) => Product.fromJson(e)).toList();

        // Filter berdasarkan vendor_id
        return allProducts
            .where((product) => product.vendorId == vendorId)
            .toList();
      } else {
        throw Exception(
          'Gagal mengambil produk vendor: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error dalam getProductsByVendor: $e');
      rethrow;
    }
  }

  // Tambahkan ke ApiService
  Future<List<Warehouse>> fetchWarehouses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/warehouses'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Warehouse.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data Warehouse');
    }
  }

  // === GOODS RECEIPT ===
  Future<List<GoodsReceipt>> fetchGoodsReceipts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/goods-receipts'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => GoodsReceipt.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data Goods Receipt');
    }
  }

  Future<void> createGoodsReceipt(GoodsReceipt gr) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/goods-receipts'),
      headers: _headers,
      body: jsonEncode(gr.toJson()),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Gagal membuat Goods Receipt: ${response.body}');
    }
  }
}
