class PurchaseOrderItem {
  final int id;
  final int productId;
  final String name;
  final double price;
  final int quantity;
  final String unit;

  PurchaseOrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      // Menangani null pada ID
      id: json['id'] is String ? int.parse(json['id']) : json['id'] ?? 0,
      // Menangani null pada product_id
      productId:
          json['product_id'] is String
              ? int.parse(json['product_id'])
              : json['product_id'] ?? 0,
      // Menangani null pada nama produk
      name: json['name'] ?? '', // Jika null, set nama kosong
      // Menangani null pada harga
      price:
          double.tryParse(json['price']?.toString() ?? '') ??
          0.0, // Jika null atau tidak valid, set harga 0.0
      // Menangani null pada kuantitas
      quantity:
          json['quantity'] is String
              ? int.parse(json['quantity'])
              : json['quantity'] ?? 0, // Jika null, set kuantitas 0
      // Menangani null pada unit
      unit: json['unit'] ?? '', // Jika null, set unit kosong
    );
  }

  Map<String, dynamic> toJson() => {
    // Sertakan ID hanya jika ID > 0
    if (id > 0) 'id': id,
    'product_id': productId,
    'name': name,
    'price': price,
    'quantity': quantity,
    'unit': unit,
  };

  PurchaseOrderItem copyWith({
    int? id,
    int? productId,
    String? name,
    double? price,
    int? quantity,
    String? unit,
  }) {
    return PurchaseOrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}
