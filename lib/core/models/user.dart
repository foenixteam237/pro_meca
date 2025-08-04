import 'package:pro_meca/core/models/company.dart';
import 'package:pro_meca/core/models/role.dart';

class User {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final bool isCompanyAdmin;
  final String? logo;
  final String? bio;
  final String? clientProfile;
  final String? technicianProfile;
  final String? managerId;
  final String createdAt;
  final String updatedAt;
  final String? companyId;
  final Role role;
  final int? roleId;
  final String? lastLogin;
  final Company? company;
  User({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    required this.isCompanyAdmin,
    this.logo,
    this.bio,
    this.clientProfile,
    this.technicianProfile,
    this.managerId,
    required this.createdAt,
    required this.updatedAt,
    this.companyId,
    this.company,
    required this.role,
    this.roleId,
    this.lastLogin,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': String id,
        'name': String name,
        'email': String? email,
        'phone': String phone,
        'isCompanyAdmin': bool isCompanyAdmin,
        'logo': String? logo,
        'bio': String? bio,
        'clientProfile': String? clientProfile,
        'technicianProfile': String? technicianProfile,
        'managerId': String? managerId,
        'createdAt': String createdAt,
        'updatedAt': String updatedAt,
        'companyId': String companyId,
        'company': Map<String, dynamic> company,
        'role': Map<String, dynamic> role,
        'lastLogin': String? lastLogin,
      } =>
        User(
          id: id,
          name: name,
          email: email,
          phone: phone,
          isCompanyAdmin: isCompanyAdmin,
          logo: logo,
          bio: bio,
          clientProfile: clientProfile,
          technicianProfile: technicianProfile,
          managerId: managerId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          companyId: companyId,
          company: Company.fromJson(company),
          role: Role.fromJson(role),
          roleId: Role.fromJson(role).id,
          lastLogin: lastLogin,
        ),
      _ => throw const FormatException('Invalid JSON format for User'),
    };
  }

  factory User.fromUserJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': String id,
        'name': String name,
        'email': String? email,
        'phone': String phone,
        'isCompanyAdmin': bool isCompanyAdmin,
        'logo': String? logo,
        'bio': String? bio,
        'clientProfile': String? clientProfile,
        'technicianProfile': String? technicianProfile,
        'managerId': String? managerId,
        'createdAt': String createdAt,
        'updatedAt': String updatedAt,
        'companyId': String companyId,
        'role': Map<String, dynamic> role,
        'lastLogin': String? lastLogin,
      } =>
        User(
          id: id,
          name: name,
          email: email,
          phone: phone,
          isCompanyAdmin: isCompanyAdmin,
          logo: logo,
          bio: bio,
          clientProfile: clientProfile,
          technicianProfile: technicianProfile,
          managerId: managerId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          companyId: companyId,
          role: Role.fromJson(role),
          roleId: Role.fromJson(role).id,
          lastLogin: lastLogin,
        ),
      _ => throw const FormatException('Invalid JSON format for User'),
    };
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'isCompanyAdmin': isCompanyAdmin,
      'logo': logo,
      'bio': bio,
      'clientProfile': clientProfile,
      'technicianProfile': technicianProfile,
      'managerId': managerId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'companyId': companyId,
      'company': company?.toJson(),
      'role': role.toJson(),
      'roleId': roleId,
      'lastLogin': lastLogin,
    };
  }
}
