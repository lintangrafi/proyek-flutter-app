import 'goods_receipt_item.dart';

class GoodsReceipt {
  final int id;
  final int poId;
  final String grNumber;
  final String tanggal;
  final String status;
  final int createdBy;
  final List<GoodsReceiptItem> items;

  GoodsReceipt({
    required this.id,
    required this.poId,
    required this.grNumber,
    required this.tanggal,
    required this.status,
    required this.createdBy,
    required this.items,
  });

  factory GoodsReceipt.fromJson(Map<String, dynamic> json) {
    return GoodsReceipt(
      id: json['id'] ?? 0,
      poId: json['po_id'] ?? 0,
      grNumber: (json['gr_number'] ?? json['grNumber'] ?? '').toString(),
      tanggal: json['tanggal'] ?? '',
      status: json['status'] ?? '',
      createdBy: json['created_by'] ?? 0,
      items:
          ((json['items'] ?? []) as List)
              .map((e) => GoodsReceiptItem.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'po_id': poId,
    'gr_number': grNumber,
    'tanggal': tanggal,
    'status': status,
    'created_by': createdBy,
    'items': items.map((e) => e.toJson()).toList(),
  };
}
