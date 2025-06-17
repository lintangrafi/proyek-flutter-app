class Product {
  final int id;
  final String name;
  final double price;
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
        json['id'] is String ? int.parse(json['id']) : json['id'] as int;

    // Parse vendor_id dengan benar (pastikan tidak null dan dikonversi ke int)
    final dynamic rawVendorId = json['vendor_id'];
    final int vendorId =
        rawVendorId is String ? int.parse(rawVendorId) : rawVendorId as int;

    // Parse price dengan benar (pastikan dikonversi ke double)
    final dynamic rawPrice = json['price'];
    final double price =
        rawPrice is String
            ? double.parse(rawPrice.replaceAll(',', ''))
            : (rawPrice is int ? rawPrice.toDouble() : rawPrice as double);

    return Product(
      id: id,
      name: json['name'] as String,
      price: price,
      unit: json['unit'] as String,
      description: json['description'] as String?,
      stock:
          json['stock'] is String
              ? int.parse(json['stock'])
              : (json['stock'] ?? 0) as int,
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
