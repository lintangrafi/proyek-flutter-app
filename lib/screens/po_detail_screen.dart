import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/purchase_order.dart';
import '../providers/purchase_order_provider.dart';

class PODetailScreen extends StatefulWidget {
  final String poId;

  const PODetailScreen({super.key, required this.poId});

  @override
  State<PODetailScreen> createState() => _PODetailScreenState();
}

class _PODetailScreenState extends State<PODetailScreen> {
  late Future<PurchaseOrder> _poFuture;

  @override
  void initState() {
    super.initState();
    _poFuture = _loadPurchaseOrder();
  }

  Future<PurchaseOrder> _loadPurchaseOrder() async {
    try {
      return Provider.of<PurchaseOrderProvider>(
        context,
        listen: false,
      ).getOrderById(int.parse(widget.poId));
    } catch (e) {
      print('Error loading purchase order: $e');
      throw Exception('Failed to load purchase order');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Purchase Order')),
      body: FutureBuilder<PurchaseOrder>(
        future: _poFuture,
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error or no data
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Gagal memuat detail PO'));
          }

          final po = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display PO details
                _buildDetailRow('Nomor PO', po.poNumber),
                _buildDetailRow('Vendor', po.vendorName),
                _buildDetailRow('Status', po.status),
                _buildDetailRow('Tanggal', po.date),

                const SizedBox(height: 24),
                // Display PO items
                const Text(
                  'Item PO',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A4A8B),
                  ),
                ),
                const SizedBox(height: 8),
                // List each item in the purchase order
                ...po.items.map(
                  (item) => ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.quantity} x ${item.unit}'),
                    trailing: Text(
                      'Rp ${(item.price * item.quantity).toStringAsFixed(2)}',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper widget to build each detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
