import 'package:flutter/material.dart';
import '../models/goods_receipt.dart';
import '../services/api_service.dart';

class GoodsReceiptProvider with ChangeNotifier {
  final ApiService apiService;
  List<GoodsReceipt> _goodsReceipts = [];
  GoodsReceiptProvider({required this.apiService});

  List<GoodsReceipt> get goodsReceipts => _goodsReceipts;

  Future<void> loadGoodsReceipts() async {
    _goodsReceipts = await apiService.fetchGoodsReceipts();
    notifyListeners();
  }

  Future<void> addGoodsReceipt(GoodsReceipt gr) async {
    await apiService.createGoodsReceipt(gr);
    await loadGoodsReceipts();
  }
}
