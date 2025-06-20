import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/purchase_order.dart';
import '../providers/purchase_order_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/vendor_provider.dart';
import '../providers/warehouse_provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VendorProvider>(context, listen: false).loadVendors();
      Provider.of<WarehouseProvider>(context, listen: false).loadWarehouses();
    });
    _poFuture = _loadPurchaseOrder();
  }

  Future<PurchaseOrder> _loadPurchaseOrder() async {
    try {
      final ordersId = Provider.of<PurchaseOrderProvider>(
        context,
        listen: false,
      ).getOrderById(int.parse(widget.poId));
      print("OrderId ${ordersId.toJson()}");
      return ordersId;
    } catch (e) {
      print('Error loading purchase order: $e');
      throw Exception('Failed to load purchase order');
    }
  }

  String formatRupiah(num number) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    print('masuk ke FutureBuilder');
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

          print('po itemnya adalah ${po.toJson()}');
          final vendorProvider = Provider.of<VendorProvider>(
            context,
            listen: false,
          );
          final warehouseProvider = Provider.of<WarehouseProvider>(
            context,
            listen: false,
          );
          final vendor = vendorProvider.getById(po.vendorId);
          final warehouse = warehouseProvider.getById(po.warehouseId);

          return SingleChildScrollView(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    po.poNumber,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color(0xFF1A4A8B),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: 8),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 80,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            po.status.toLowerCase() ==
                                                    'disetujui'
                                                ? Colors.green[50]
                                                : po.status.toLowerCase() ==
                                                    'ditolak'
                                                ? Colors.red[50]
                                                : Colors.orange[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        po.status,
                                        style: TextStyle(
                                          color:
                                              po.status.toLowerCase() ==
                                                      'disetujui'
                                                  ? Colors.green[700]
                                                  : po.status.toLowerCase() ==
                                                      'ditolak'
                                                  ? Colors.red[700]
                                                  : Colors.orange[700],
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
                                    'Vendor: ${vendor.name}',
                                    style: const TextStyle(color: Colors.grey),
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
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
                                    'Gudang: ${warehouse.name}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          po.date,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    const Text(
                      'Daftar Item',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A4A8B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...po.items.map(
                      (item) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFEDF4FB),
                            child: Text(
                              item.name.isNotEmpty ? item.name[0] : '?',
                              style: const TextStyle(color: Color(0xFF1A4A8B)),
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${item.quantity} ${item.unit}'),
                          trailing: Text(
                            formatRupiah(item.price * item.quantity),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A4A8B),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          formatRupiah(po.total),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color(0xFF1A4A8B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Builder(
                      builder: (context) {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        final isManager =
                            authProvider.currentUser?.role == 'manager';
                        if (isManager &&
                            (po.status.toLowerCase() == 'draft' ||
                                po.status.toLowerCase() ==
                                    'menunggu persetujuan' ||
                                po.status.toLowerCase() == 'pending')) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Approve PO'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Konfirmasi Approve'),
                                    content: const Text('Apakah Anda yakin ingin menyetujui PO ini?'),
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
                                  builder: (ctx) => const Center(child: CircularProgressIndicator()),
                                );
                                try {
                                  await Provider.of<PurchaseOrderProvider>(
                                    context,
                                    listen: false,
                                  ).approveOrder(po.id);
                                  await Provider.of<PurchaseOrderProvider>(
                                    context,
                                    listen: false,
                                  ).loadPurchaseOrders();
                                  setState(() {
                                    _poFuture = _loadPurchaseOrder();
                                  });
                                  Navigator.pop(context); // close loading
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('PO berhasil di-approve.'),
                                    ),
                                  );
                                } catch (e) {
                                  Navigator.pop(context); // close loading
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal approve PO: $e'),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
