import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/purchase_order.dart';
import '../models/purchase_order_item.dart';
import '../models/product.dart';
import '../providers/purchase_order_provider.dart';
import '../providers/vendor_provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart'; // Tambahkan import ini

class CreatePOScreen extends StatefulWidget {
  const CreatePOScreen({super.key});
  @override
  State<CreatePOScreen> createState() => _CreatePOScreenState();
}

class _CreatePOScreenState extends State<CreatePOScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _generatedPoNumber;
  int? _selectedVendorId;
  DateTime? _selectedDate;
  final List<PurchaseOrderItem> _items = [];
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _poNumberController = TextEditingController();
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProvider>().loadVendors();
    });
  }

  void _generatePoNumber(DateTime date) {
    final poProvider = context.read<PurchaseOrderProvider>();
    final existingOrders = poProvider.orders;
    final dateOnlyString = DateFormat('yyyy-MM-dd').format(date);
    final countForDate =
        existingOrders.where((po) => po.date.startsWith(dateOnlyString)).length;
    final dateStringForPo = DateFormat('yyyyMMdd').format(date);
    final sequenceNumber = (countForDate + 1).toString().padLeft(3, '0');
    setState(() {
      _generatedPoNumber = 'PO-$dateStringForPo-$sequenceNumber';
      _poNumberController.text = _generatedPoNumber!;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    if (_items.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal tidak dapat diubah setelah menambahkan item'),
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
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
      _generatePoNumber(picked);
    }
  }

  Future<List<Product>> _loadVendorProducts(int vendorId) async {
    setState(() {
      _isLoadingProducts = true;
    });
    try {
      final productProvider = context.read<ProductProvider>();
      await productProvider.loadProductsForVendor(vendorId);
      final products = productProvider.products;
      if (products.isEmpty) {
        await productProvider.loadAllProducts();
        final allProducts = productProvider.products;
        final filteredProducts =
            allProducts
                .where((product) => product.vendorId == vendorId)
                .toList();
        return filteredProducts;
      }
      return products;
    } catch (e) {
      print('Error memuat produk: $e');
      rethrow;
    } finally {
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  Future<void> _addItemDialog() async {
    if (_selectedVendorId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih vendor terlebih dahulu')),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Memuat produk..."),
              ],
            ),
          ),
    );
    List<Product> products = [];
    try {
      products = await _loadVendorProducts(_selectedVendorId!);
      if (!mounted) return;
      Navigator.pop(context);
      if (products.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada produk tersedia untuk vendor ini'),
          ),
        );
        return;
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat produk: $e')));
      return;
    }
    Product? selectedProduct;
    int quantity = 1;
    final priceController = TextEditingController();

    if (!mounted) return;
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Tambah Item'),
            content: StatefulBuilder(
              builder: (context, setStateDialog) {
                return SizedBox(
                  height: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<Product>(
                        decoration: const InputDecoration(
                          labelText: 'Pilih Produk',
                        ),
                        value: selectedProduct,
                        isExpanded: true,
                        items:
                            products
                                .map(
                                  (p) => DropdownMenuItem<Product>(
                                    value: p,
                                    child: Text(
                                      p.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (Product? value) {
                          setStateDialog(() {
                            selectedProduct = value;
                            if (selectedProduct != null) {
                              priceController.text = selectedProduct!.price
                                  .toStringAsFixed(2);
                            } else {
                              priceController.clear();
                            }
                          });
                        },
                        validator:
                            (value) =>
                                value == null
                                    ? 'Pilih produk terlebih dahulu'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: '1',
                        decoration: const InputDecoration(
                          labelText: 'Kuantitas',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          quantity = int.tryParse(val) ?? 1;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Harga'),
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                child: const Text('Tambah'),
                onPressed: () {
                  if (selectedProduct == null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Pilih produk terlebih dahulu'),
                      ),
                    );
                    return;
                  }
                  if (quantity <= 0) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Kuantitas harus lebih dari 0'),
                      ),
                    );
                    return;
                  }
                  final price = double.tryParse(priceController.text);
                  if (price == null || price <= 0) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Harga tidak valid')),
                    );
                    return;
                  }

                  final existingItemIndex = _items.indexWhere(
                    (item) => item.productId == selectedProduct!.id,
                  );
                  setState(() {
                    if (existingItemIndex >= 0) {
                      final existingItem = _items[existingItemIndex];
                      _items[existingItemIndex] = PurchaseOrderItem(
                        id: existingItem.id,
                        productId: existingItem.productId,
                        name: existingItem.name,
                        price: price,
                        quantity: existingItem.quantity + quantity,
                        unit: existingItem.unit,
                      );
                    } else {
                      final newItem = PurchaseOrderItem(
                        id: 0,
                        productId: selectedProduct!.id,
                        name: selectedProduct!.name,
                        price: price,
                        quantity: quantity,
                        unit: selectedProduct!.unit,
                      );
                      _items.add(newItem);
                    }
                  });

                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
    );
  }

  Future<void> _savePO() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap perbaiki error pada form.')),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal PO harus dipilih.')),
      );
      return;
    }
    if (_selectedVendorId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vendor harus dipilih.')));
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal satu item ke PO.')),
      );
      return;
    }
    if (_generatedPoNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nomor PO belum tergenerate. Pilih tanggal terlebih dahulu.',
          ),
        ),
      );
      return;
    }

    // === AMBIL ID USER AKTIF DARI AUTHPROVIDER ===
    final authProvider = context.read<AuthProvider>();
    if (authProvider.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User belum login atau mengambil ID user gagal.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Menyimpan Purchase Order..."),
              ],
            ),
          ),
    );

    try {
      final vendorProvider = context.read<VendorProvider>();
      final vendorName = vendorProvider.getById(_selectedVendorId!).name;
      final total = _items.fold<double>(
        0.0,
        (sum, item) => sum + (item.price * item.quantity),
      );

      // === Tambahkan createdBy sesuai user id ===
      final newPO = PurchaseOrder(
        id: 0,
        poNumber: _generatedPoNumber!,
        vendorId: _selectedVendorId!,
        vendorName: vendorName,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        total: total,
        status: 'Menunggu Persetujuan',
        items: List.from(_items),
        createdBy: authProvider.userId!, // <--- INI YANG PENTING!
      );

      final poProvider = context.read<PurchaseOrderProvider>();
      await poProvider.addOrder(newPO);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PO ${newPO.poNumber} berhasil disimpan.')),
      );
      await context.read<PurchaseOrderProvider>().loadPurchaseOrders();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      Navigator.pop(context);
      print("Exception during save PO: $error");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan PO: $error')));
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _poNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.watch<VendorProvider>();
    final bool canEditVendor = _items.isEmpty;
    final bool canEditDate = _items.isEmpty;
    final vendors = vendorProvider.vendors;

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Purchase Order')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal PO',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: canEditDate ? () => _selectDate(context) : null,
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Pilih tanggal PO'
                            : null,
                style: TextStyle(
                  color: canEditDate ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nomor PO (Otomatis)',
                ),
                readOnly: true,
                controller: _poNumberController,
              ),
              const SizedBox(height: 16),
              vendors.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                    value: _selectedVendorId,
                    decoration: const InputDecoration(labelText: 'Vendor'),
                    onChanged:
                        canEditVendor
                            ? (value) {
                              setState(() {
                                _selectedVendorId = value;
                                _items.clear();
                              });
                            }
                            : null,
                    items:
                        vendors
                            .map(
                              (v) => DropdownMenuItem<int>(
                                value: v.id,
                                child: Text(v.name),
                              ),
                            )
                            .toList(),
                    validator:
                        (value) =>
                            value == null ? 'Vendor harus dipilih' : null,
                    style: TextStyle(
                      color: canEditVendor ? Colors.black : Colors.grey,
                    ),
                  ),
              const SizedBox(height: 16),
              if (_selectedVendorId != null)
                ElevatedButton.icon(
                  onPressed: _isLoadingProducts ? null : _addItemDialog,
                  icon:
                      _isLoadingProducts
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.add),
                  label: Text(_isLoadingProducts ? 'Memuat...' : 'Tambah Item'),
                ),
              const SizedBox(height: 16),
              if (_items.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daftar Item',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._items.map(
                      (item) => ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          'Harga: ${item.price}, Qty: ${item.quantity}, Unit: ${item.unit}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _items.remove(item);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _savePO,
                child: const Text('Simpan PO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
