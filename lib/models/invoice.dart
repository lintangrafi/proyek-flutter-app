class Invoice {
  final int id;
  final String invoiceNumber;
  final int grId;
  final String grNumber;
  final String date;
  final num total;
  final String status;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.grId,
    required this.grNumber,
    required this.date,
    required this.total,
    required this.status,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      grId: json['gr_id'] ?? 0,
      grNumber: json['gr_number'] ?? '',
      date: json['date'] ?? '',
      total: num.tryParse(json['total'].toString()) ?? 0,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'gr_id': grId,
      'gr_number': grNumber,
      'date': date,
      'total': total,
      'status': status,
    };
  }
}
