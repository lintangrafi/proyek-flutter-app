import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/purchase_order.dart';

class PurchaseOrderProvider with ChangeNotifier {
  final ApiService apiService;
  List<PurchaseOrder> _orders = [];

  PurchaseOrderProvider({required this.apiService});

  List<PurchaseOrder> get orders => _orders;

  Future<void> loadPurchaseOrders() async {
    _orders = await apiService.fetchPurchaseOrders();
    notifyListeners();
  }

  Future<void> addOrder(PurchaseOrder po) async {
    final newOrder = await apiService.createPurchaseOrder(po);
    _orders.add(newOrder);
    notifyListeners();
  }

  Future<bool> updateOrderStatus(int id, String status) async {
    final ok = await apiService.updateOrderStatus(id, status);
    if (ok) {
      final idx = _orders.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _orders[idx] = _orders[idx].copyWith(status: status);
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<void> approveOrder(int id) async {
    await updateOrderStatus(id, 'Approved');
  }

  PurchaseOrder getOrderById(int id) {
    return _orders.firstWhere(
      (po) => po.id == id,
      orElse: () => throw Exception("PO tidak ditemukan"),
    );
  }

  Future<void> refreshOrders() async {
    await loadPurchaseOrders();
  }

  loadOrders() {}
}
