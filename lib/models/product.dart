class Product {
  final int id;
  final String name;
  final num price;
  final String unit;
  final String? description;
  final int stock;
  final int vendorId; // Field untuk vendor_id

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    this.description,
    this.stock = 0,
    required this.vendorId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Pastikan mengonversi nilai ke tipe data yang benar
    final int id =
        json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0;

    // Parse vendor_id dengan aman (jika null, fallback ke 0)
    final int vendorId =
        json['vendor_id'] != null
            ? int.tryParse(json['vendor_id'].toString()) ?? 0
            : 0;

    // Parse price dengan benar (pastikan dikonversi ke double)
    final num price =
        json['price'] != null
            ? num.tryParse(json['price'].toString().replaceAll(',', '')) ?? 0.0
            : 0;

    return Product(
      id: id,
      name: json['name'] as String,
      price: price,
      unit: json['unit'] as String,
      description: json['description'] as String?,
      stock:
          json['stock'] != null
              ? int.tryParse(json['stock'].toString()) ?? 0
              : 0,
      vendorId: vendorId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'unit': unit,
    'description': description,
    'stock': stock,
    'vendor_id': vendorId,
  };
}
