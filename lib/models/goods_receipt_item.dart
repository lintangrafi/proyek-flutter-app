class GoodsReceiptItem {
  final int id;
  final int poItemId;
  final int qtyReceived;
  final String condition;

  GoodsReceiptItem({
    required this.id,
    required this.poItemId,
    required this.qtyReceived,
    required this.condition,
  });

  factory GoodsReceiptItem.fromJson(Map<String, dynamic> json) {
    return GoodsReceiptItem(
      id: json['id'] ?? 0,
      poItemId: json['po_item_id'] ?? 0,
      qtyReceived: json['qty_received'] ?? 0,
      condition: json['condition'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'po_item_id': poItemId,
    'qty_received': qtyReceived,
    'condition': condition,
  };
}
