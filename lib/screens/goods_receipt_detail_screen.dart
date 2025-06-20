import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goods_receipt_provider.dart';
import '../models/goods_receipt.dart';
import '../providers/auth_provider.dart';
import '../providers/purchase_order_provider.dart';
import '../models/purchase_order_item.dart';
import '../providers/vendor_provider.dart';
import '../providers/warehouse_provider.dart';
import '../models/vendor.dart';
import '../models/warehouse.dart';
import '../models/purchase_order.dart';

class GoodsReceiptDetailScreen extends StatelessWidget {
  final int grId;
  const GoodsReceiptDetailScreen({super.key, required this.grId});

  @override
  Widget build(BuildContext context) {
    final grProvider = Provider.of<GoodsReceiptProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final poProvider = Provider.of<PurchaseOrderProvider>(
      context,
      listen: false,
    );
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    final warehouseProvider = Provider.of<WarehouseProvider>(
      context,
      listen: false,
    );
    final userRole = authProvider.currentUser?.role ?? '';
    GoodsReceipt? gr;
    String poNumber = '';
    try {
      gr = grProvider.goodsReceipts.firstWhere((g) => g.id == grId);
    } catch (e) {
      gr = null;
    }
    if (gr != null) {
      try {
        final poId = gr.poId;
        poNumber = poProvider.orders.firstWhere((po) => po.id == poId).poNumber;
      } catch (e) {
        poNumber = gr.poId.toString();
      }
    }

    PurchaseOrder? getPOById(int? id) {
      if (id == null) return null;
      try {
        return poProvider.orders.firstWhere((po) => po.id == id);
      } catch (_) {
        return null;
      }
    }

    Vendor? vendor;
    Warehouse? warehouse;
    if (gr != null) {
      final po = getPOById(gr.poId);
      if (po != null) {
        vendor = vendorProvider.getById(po.vendorId);
        warehouse = warehouseProvider.getById(po.warehouseId);
      }
    }

    if (gr == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Goods Receipt')),
        body: const Center(child: Text('Goods Receipt tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(gr.grNumber.isNotEmpty ? gr.grNumber : 'GR#${gr.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Card(
          margin: const EdgeInsets.all(16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gr.grNumber.isNotEmpty
                                ? gr.grNumber
                                : 'GR#{gr.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF1A4A8B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PO Number: $poNumber',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 80),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              gr.status.toLowerCase() == 'pending'
                                  ? Colors.orange[100]
                                  : Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          gr.status,
                          style: TextStyle(
                            color:
                                gr.status.toLowerCase() == 'pending'
                                    ? Colors.orange
                                    : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tanggal: ${gr.tanggal}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.store, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Vendor: ${vendor?.name ?? 'Tidak ditemukan'}',
                      style: const TextStyle(color: Colors.grey),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.warehouse, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Gudang: ${warehouse?.name ?? 'Tidak ditemukan'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Daftar Item:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...gr.items.map((item) {
                  PurchaseOrderItem? poItem;
                  try {
                    final po = poProvider.orders.firstWhere(
                      (po) => po.id == gr!.poId,
                    );
                    poItem = po.items.firstWhere((i) => i.id == item.poItemId);
                  } catch (e) {
                    poItem = null;
                  }
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        poItem != null ? poItem.name : 'Item #${item.poItemId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Qty Diterima: ${item.qtyReceived} ${poItem?.unit ?? ''}',
                          ),
                          if (poItem != null)
                            Text('Qty PO: ${poItem.quantity} ${poItem.unit}'),
                          if (poItem != null)
                            Text(
                              'Harga: Rp ${poItem.price.toStringAsFixed(0)}',
                            ),
                          Text('Kondisi: ${item.condition}'),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                if (userRole.toLowerCase() == 'manager' &&
                    gr.status.toLowerCase() == 'pending')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Completed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: const Text(
                                'Tandai Goods Receipt ini sebagai Completed?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Ya'),
                                ),
                              ],
                            ),
                      );
                      if (confirm != true) return;
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (ctx) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      );
                      final ok = await grProvider.updateGoodsReceiptStatus(
                        gr!.id,
                        'Completed',
                      );
                      Navigator.pop(context); // close loading
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Status GR berhasil diubah menjadi Completed.',
                            ),
                          ),
                        );
                        Navigator.pop(
                          context,
                          true,
                        ); // kembali ke list dan refresh
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal update status GR.'),
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
