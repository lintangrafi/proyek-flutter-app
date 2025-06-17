import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/vendor.dart';

class VendorProvider with ChangeNotifier {
  final ApiService apiService;
  List<Vendor> _vendors = [];
  VendorProvider({required this.apiService});

  List<Vendor> get vendors => _vendors;

  Future<void> loadVendors() async {
    _vendors = await apiService.fetchVendors();
    notifyListeners();
  }

  Vendor getById(int id) {
    return _vendors.firstWhere(
      (vendor) => vendor.id == id,
      orElse: () => throw Exception("Vendor tidak ditemukan"),
    );
  }
}
