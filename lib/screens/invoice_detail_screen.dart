import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../providers/invoice_provider.dart';
import '../providers/goods_receipt_provider.dart';
import '../providers/purchase_order_provider.dart';
import '../providers/vendor_provider.dart';
import '../providers/warehouse_provider.dart';
import '../models/goods_receipt.dart';
import '../models/purchase_order.dart';
import '../models/purchase_order_item.dart';
import '../models/vendor.dart';
import '../models/warehouse.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final int invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final grProvider = Provider.of<GoodsReceiptProvider>(context);
    final poProvider = Provider.of<PurchaseOrderProvider>(context);
    final invoice = invoiceProvider.invoices.firstWhere(
      (inv) => inv.id == invoiceId,
      orElse:
          () => Invoice(
            id: 0,
            invoiceNumber: '',
            grId: 0,
            grNumber: '',
            date: '',
            total: 0,
            status: '',
          ),
    );
    final gr = grProvider.goodsReceipts.firstWhere(
      (g) => g.id == invoice.grId,
      orElse:
          () => GoodsReceipt(
            id: 0,
            poId: 0,
            grNumber: '',
            tanggal: '',
            status: '',
            createdBy: 0,
            items: const [],
          ),
    );
    final po =
        poProvider.orders.isNotEmpty
            ? poProvider.orders.firstWhere(
              (p) => p.id == gr.poId,
              orElse:
                  () => PurchaseOrder(
                    id: 0,
                    poNumber: '',
                    vendorId: 0,
                    vendorName: '',
                    date: '',
                    total: 0,
                    status: '',
                    items: const [],
                    createdBy: 0,
                    warehouseId: 0,
                  ),
            )
            : null;

    Vendor? vendor;
    Warehouse? warehouse;
    if (po != null) {
      try {
        vendor = Provider.of<VendorProvider>(
          context,
          listen: false,
        ).getById(po.vendorId);
        warehouse = Provider.of<WarehouseProvider>(
          context,
          listen: false,
        ).getById(po.warehouseId);
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          invoice.invoiceNumber.isNotEmpty
              ? invoice.invoiceNumber
              : 'Invoice#${invoice.id}',
        ),
      ),
      body:
          invoice.id == 0
              ? const Center(child: Text('Invoice tidak ditemukan'))
              : SingleChildScrollView(
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
                                    invoice.invoiceNumber.isNotEmpty
                                        ? invoice.invoiceNumber
                                        : 'Invoice#${invoice.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.teal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'GR Number: ${gr.grNumber}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.store,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Vendor: ${vendor?.name ?? po?.vendorName ?? '-'}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.warehouse,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Gudang: ${warehouse?.name ?? po?.warehouseId ?? '-'}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      invoice.status.toLowerCase() == 'draft'
                                          ? Colors.orange[100]
                                          : Colors.green[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  invoice.status,
                                  style: TextStyle(
                                    color:
                                        invoice.status.toLowerCase() == 'draft'
                                            ? Colors.orange
                                            : Colors.green,
                                    fontWeight: FontWeight.bold,
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
                              'Tanggal: ${invoice.date}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Daftar Item:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...gr.items.map((item) {
                          PurchaseOrderItem? poItem;
                          try {
                            poItem =
                                po != null
                                    ? po.items.firstWhere(
                                      (i) => i.id == item.poItemId,
                                    )
                                    : null;
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
                                poItem?.name ?? 'Item #${item.poItemId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Qty: ${item.qtyReceived} ${poItem?.unit ?? ''}',
                                  ),
                                  if (poItem != null)
                                    Text(
                                      'Harga: Rp ${poItem.price.toStringAsFixed(0)}',
                                    ),
                                  Text('Kondisi: ${item.condition}'),
                                ],
                              ),
                              trailing: Text(
                                'Rp ${(item.qtyReceived * (poItem?.price ?? 0)).toStringAsFixed(0)}',
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        Text(
                          'Total: Rp ${invoice.total.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        if (invoice.status.toLowerCase() == 'draft')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.payment),
                              label: const Text('Tandai sebagai Paid'),
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
                                          'Tandai invoice ini sebagai Paid?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(ctx, false),
                                            child: const Text('Batal'),
                                          ),
                                          ElevatedButton(
                                            onPressed:
                                                () => Navigator.pop(ctx, true),
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
                                final ok = await invoiceProvider
                                    .updateInvoiceStatus(invoice.id, 'Paid');
                                Navigator.pop(context); // close loading
                                if (ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Invoice berhasil ditandai sebagai Paid.',
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context, true);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Gagal update status invoice.',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
