class Client {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String phone;
  final String? address;
  final String? city;
  final String? logo;
  final String? userId;
  final String? clientCompany;
  final String companyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.phone,
    this.address,
    this.city,
    this.logo,
    this.userId,
    this.clientCompany,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      logo: json['logo'] as String?,
      userId: json['userId'] as String?,
      clientCompany: json['clientCompany'] as String?,
      companyId: json['companyId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'logo': logo,
      'userId': userId,
      'clientCompany': clientCompany,
      'companyId': companyId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

}