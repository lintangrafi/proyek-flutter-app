import 'purchase_order_item.dart';

class PurchaseOrder {
  final int id;
  final String poNumber;
  final int vendorId;
  final String vendorName;
  final String date;
  final double total;
  final String status;
  final List<PurchaseOrderItem> items;
  final int createdBy;
  final int warehouseId;

  PurchaseOrder({
    required this.id,
    required this.poNumber,
    required this.vendorId,
    required this.vendorName,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
    required this.createdBy,
    required this.warehouseId,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id:
          json['id'] is String
              ? int.parse(json['id'])
              : json['id'] ?? 0, // Handling null and string to int
      poNumber:
          json['po_number'] ??
          json['poNumber'] ??
          '', // Fallback to empty string if null
      vendorId:
          json['vendor_id'] is String
              ? int.parse(json['vendor_id'])
              : json['vendor_id'] ?? 0, // Ensure vendorId is parsed correctly
      vendorName:
          json['vendor_name'] ??
          json['vendorName'] ??
          '', // Fallback to empty string if null
      date: json['date'] ?? '', // Fallback to empty string if null
      total:
          double.tryParse(json['total'].toString()) ??
          0.0, // Ensure total is a double, fallback if null or invalid
      status: json['status'] ?? '', // Fallback to empty string if null
      createdBy:
          json['created_by'] is String
              ? int.parse(json['created_by'])
              : json['created_by'] ?? 0, // Ensure createdBy is parsed correctly
      items:
          ((json['items'] as List<dynamic>?) ?? [])
              .map((item) => PurchaseOrderItem.fromJson(item))
              .toList(), // Ensure items are properly parsed
      warehouseId:
          json['warehouse_id'] is String
              ? int.parse(json['warehouse_id'])
              : json['warehouse_id'] ??
                  0, // Ensure warehouseId is parsed correctly
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id > 0) 'id': id, // Include id only if it is greater than 0
      'po_number': poNumber,
      'vendor_id': vendorId,
      'vendor_name': vendorName,
      'date': date,
      'total': total,
      'status': status,
      'created_by': createdBy,
      'warehouse_id': warehouseId,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  PurchaseOrder copyWith({
    int? id,
    String? poNumber,
    int? vendorId,
    String? vendorName,
    String? date,
    double? total,
    String? status,
    List<PurchaseOrderItem>? items,
    int? createdBy,
    int? warehouseId,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      date: date ?? this.date,
      total: total ?? this.total,
      status: status ?? this.status,
      items: items ?? this.items,
      createdBy: createdBy ?? this.createdBy,
      warehouseId: warehouseId ?? this.warehouseId,
    );
  }
}
