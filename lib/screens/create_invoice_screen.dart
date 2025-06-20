import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/invoice_provider.dart';
import '../models/invoice.dart';
import '../providers/goods_receipt_provider.dart';
import '../models/goods_receipt.dart';
import '../providers/purchase_order_provider.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  int? selectedGRId;
  String invoiceNumber = '';
  String date = '';
  double total = 0;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    date = DateTime.now().toIso8601String().substring(0, 10);
  }

  @override
  Widget build(BuildContext context) {
    final grProvider = Provider.of<GoodsReceiptProvider>(context);
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final poProvider = Provider.of<PurchaseOrderProvider>(context);
    // Ambil id GR yang sudah pernah dibuat invoice
    final usedGrIds = invoiceProvider.invoices.map((inv) => inv.grId).toSet();
    // Filter hanya GR completed yang belum pernah dibuat invoice
    final availableGRs =
        grProvider.goodsReceipts
            .where(
              (g) =>
                  (g.status.toLowerCase() == 'completed' ||
                      g.status.toLowerCase() == 'selesai') &&
                  !usedGrIds.contains(g.id),
            )
            .toList();

    final getPOItem = (GoodsReceipt gr, int poItemId) {
      try {
        final po = poProvider.orders.firstWhere((po) => po.id == gr.poId);
        return po.items.firstWhere((i) => i.id == poItemId);
      } catch (e) {
        return null;
      }
    };

    GoodsReceipt? getGRById(List<GoodsReceipt> grs, int? id) {
      if (id == null) return null;
      try {
        return grs.firstWhere((g) => g.id == id);
      } catch (_) {
        return null;
      }
    }

    // Reset selectedGRId if not in availableGRs
    if (selectedGRId != null &&
        !availableGRs.any((g) => g.id == selectedGRId)) {
      selectedGRId = null;
    }
    final selectedGR = getGRById(availableGRs, selectedGRId);

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Invoice')),
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
                const Text(
                  'Pilih Goods Receipt (Completed):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<int>(
                  isExpanded: true,
                  value: selectedGRId,
                  hint: const Text('Pilih GR'),
                  items:
                      availableGRs
                          .map(
                            (gr) => DropdownMenuItem(
                              value: gr.id,
                              child: Text(
                                gr.grNumber.isNotEmpty
                                    ? gr.grNumber
                                    : 'GR#${gr.id}',
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (grId) {
                    setState(() {
                      selectedGRId = grId;
                      final gr = getGRById(availableGRs, grId);
                      total =
                          gr != null
                              ? gr.items.fold(0.0, (sum, item) {
                                final poItem = getPOItem(gr, item.poItemId);
                                return sum +
                                    (item.qtyReceived * (poItem?.price ?? 0));
                              })
                              : 0.0;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text('Tanggal: $date'),
                const SizedBox(height: 16),
                if (selectedGR != null) ...[
                  const Text(
                    'Daftar Item:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...selectedGR.items.map((item) {
                    final poItem = getPOItem(selectedGR, item.poItemId);
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          poItem?.name ?? 'Item #${item.poItemId}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                    'Total: Rp ${total.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label:
                        isLoading
                            ? const Text('Menyimpan...')
                            : const Text('Simpan Invoice'),
                    onPressed:
                        isLoading || selectedGR == null
                            ? null
                            : () async {
                              setState(() {
                                isLoading = true;
                                error = null;
                              });
                              try {
                                await invoiceProvider.addInvoice(
                                  Invoice(
                                    id: 0,
                                    invoiceNumber: '',
                                    grId: selectedGR.id,
                                    grNumber: selectedGR.grNumber,
                                    date: date,
                                    total: total,
                                    status: 'Draft',
                                  ),
                                );
                                Navigator.pop(context, true);
                              } catch (e) {
                                setState(() {
                                  error = 'Gagal menyimpan invoice: $e';
                                });
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });
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
