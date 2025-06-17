class Vendor {
  final int id;
  final String name;
  final String phone;
  final String? address;
  final String? email;

  Vendor({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.email,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
    id: json['id'] as int,
    name: json['name'],
    phone: json['phone'],
    address: json['address'],
    email: json['email'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
    'email': email,
  };
}
