import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/api_service.dart';

class InvoiceProvider with ChangeNotifier {
  final ApiService apiService;
  List<Invoice> _invoices = [];
  InvoiceProvider({required this.apiService});

  List<Invoice> get invoices => _invoices;

  Future<void> loadInvoices() async {
    _invoices = await apiService.fetchInvoices();
    notifyListeners();
  }

  Future<void> addInvoice(Invoice invoice) async {
    await apiService.createInvoice(invoice);
    await loadInvoices();
  }

  Future<bool> updateInvoiceStatus(int id, String status) async {
    final ok = await apiService.updateInvoiceStatus(id, status);
    if (ok) {
      await loadInvoices();
    }
    return ok;
  }
}
