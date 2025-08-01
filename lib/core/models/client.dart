
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String?,
      phone: json['phone'].toString(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      logo: json['logo'] as String?,
      userId: json['userId'] as String?,
      clientCompany: json['clientCompany'] as String?,
      companyId: json['companyId'] as String
    );
  }
  factory Client.fromJsn(Map<String, dynamic> json) {
    return Client(
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      id: '',
      companyId: '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email.toString(),
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (logo != null) 'logo': logo,
      if (userId != null) 'userId': userId,
      if (clientCompany != null) 'clientCompany': clientCompany,
      'companyId': companyId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return{
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
    };
  }
}
