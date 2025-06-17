import 'package:flutter/material.dart';
import '../models/warehouse.dart';
import '../services/api_service.dart';

class WarehouseProvider with ChangeNotifier {
  final ApiService apiService;
  List<Warehouse> _warehouses = [];
  WarehouseProvider({required this.apiService});

  List<Warehouse> get warehouses => _warehouses;

  Future<void> loadWarehouses() async {
    _warehouses = await apiService.fetchWarehouses();
    notifyListeners();
  }

  Warehouse getById(int id) {
    return _warehouses.firstWhere(
      (w) => w.id == id,
      orElse: () => throw Exception("Warehouse tidak ditemukan"),
    );
  }
}
