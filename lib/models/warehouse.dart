class Warehouse {
  final int id;
  final String name;
  final String? address;

  Warehouse({required this.id, required this.name, this.address});

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }
}
