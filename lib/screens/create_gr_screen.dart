import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goods_receipt.dart';
import '../models/goods_receipt_item.dart';
import '../models/purchase_order.dart';
import '../models/purchase_order_item.dart';
import '../providers/goods_receipt_provider.dart';
import '../providers/purchase_order_provider.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class CreateGoodsReceiptScreen extends StatefulWidget {
  const CreateGoodsReceiptScreen({super.key});
  @override
  State<CreateGoodsReceiptScreen> createState() =>
      _CreateGoodsReceiptScreenState();
}

class _CreateGoodsReceiptScreenState extends State<CreateGoodsReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedPoId;
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  final List<GoodsReceiptItem> _items = [];
  Map<int, TextEditingController> _qtyControllers = {};
  Map<int, TextEditingController> _conditionControllers = {};

  @override
  void dispose() {
    _dateController.dispose();
    _qtyControllers.values.forEach((c) => c.dispose());
    _conditionControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final poProvider = context.watch<PurchaseOrderProvider>();
    final grProvider = context.watch<GoodsReceiptProvider>();
    final authProvider = context.read<AuthProvider>();
    final approvedPOs =
        poProvider.orders
            .where(
              (po) =>
                  (po.status.toLowerCase() == 'disetujui' ||
                      po.status.toLowerCase() == 'approved') &&
                  !grProvider.goodsReceipts.any((gr) => gr.poId == po.id),
            )
            .toList();
    PurchaseOrder? selectedPO =
        _selectedPoId != null
            ? poProvider.orders.firstWhere((po) => po.id == _selectedPoId)
            : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Goods Receipt')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedPoId,
                decoration: const InputDecoration(
                  labelText: 'Pilih PO (Approved)',
                ),
                items:
                    approvedPOs
                        .map(
                          (po) => DropdownMenuItem<int>(
                            value: po.id,
                            child: Text(po.poNumber),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedPoId = val;
                    _items.clear();
                    _qtyControllers.clear();
                    _conditionControllers.clear();
                  });
                },
                validator: (val) => val == null ? 'Pilih PO' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Penerimaan',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Pilih tanggal'
                            : null,
              ),
              const SizedBox(height: 16),
              if (selectedPO != null)
                ...selectedPO.items.map((item) {
                  _qtyControllers[item.id] ??= TextEditingController();
                  _conditionControllers[item.id] ??= TextEditingController();
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Qty PO: ${item.quantity} ${item.unit}'),
                          TextFormField(
                            controller: _qtyControllers[item.id],
                            decoration: const InputDecoration(
                              labelText: 'Qty Diterima',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              final qty = int.tryParse(val ?? '');
                              if (qty == null || qty < 1)
                                return 'Qty wajib > 0';
                              if (qty > item.quantity) return 'Qty melebihi PO';
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _conditionControllers[item.id],
                            decoration: const InputDecoration(
                              labelText: 'Kondisi Barang',
                            ),
                            validator:
                                (val) =>
                                    (val == null || val.isEmpty)
                                        ? 'Kondisi wajib diisi'
                                        : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate() || selectedPO == null)
                    return;
                  final items =
                      selectedPO.items
                          .map(
                            (item) => GoodsReceiptItem(
                              id: 0,
                              poItemId: item.id,
                              qtyReceived:
                                  int.tryParse(
                                    _qtyControllers[item.id]?.text ?? '',
                                  ) ??
                                  0,
                              condition:
                                  _conditionControllers[item.id]?.text ?? '',
                            ),
                          )
                          .toList();
                  final gr = GoodsReceipt(
                    id: 0,
                    poId: selectedPO.id,
                    grNumber: 'GR-${DateTime.now().millisecondsSinceEpoch}',
                    tanggal: _dateController.text,
                    status: 'Pending',
                    createdBy: authProvider.userId ?? 0,
                    items: items,
                  );
                  await grProvider.addGoodsReceipt(gr);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Goods Receipt berhasil disimpan.'),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Simpan GR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
