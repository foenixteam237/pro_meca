import 'dart:io';
import 'package:pro_meca/core/models/company.dart';
import 'package:pro_meca/core/models/role.dart';
import 'package:dio/dio.dart';

class User {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final bool isCompanyAdmin;
  final bool isVerified;
  final bool isActive;
  final String? logo;
  final String? bio;
  final ClientProfile? clientProfile;
  final TechnicianProfile? technicianProfile;
  final String? managerId;
  final String? createdAt;
  final String? updatedAt;
  final String? companyId;
  final Role role;
  final int? roleId;
  final String? lastLogin;
  final Company? company;
  // final List<String>? formations;
  // final String? expertise;

  User({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    required this.isCompanyAdmin,
    required this.isVerified,
    required this.isActive,
    this.logo,
    this.bio,
    this.clientProfile,
    this.technicianProfile,
    this.managerId,
    this.createdAt,
    this.updatedAt,
    this.companyId,
    this.company,
    required this.role,
    this.roleId,
    this.lastLogin,
    // this.formations,
    // this.expertise,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print(json);
    // return User.fromUserJson(json);
    return switch (json) {
      {
        'id': String id,
        'name': String name,
        'email': String? email,
        'phone':
            String
            phone, //TODO: phone au format [+237]_[677333312] remplacer partout
        'isCompanyAdmin': bool isCompanyAdmin,
        'isVerified': bool isVerified,
        'isActive': bool isActive,
        'logo': String? logo,
        'bio': String? bio,
        'clientProfile':
            Map<String, dynamic>?
            clientProfile, //TODO: la vérification d'utilisation coté client sera amélioré dans une prochaine version
        'technicianProfile': Map<String, dynamic>? technicianProfile,
        'managerId': String? managerId,
        'createdAt': String? createdAt,
        'updatedAt': String? updatedAt,
        'companyId': String companyId,
        'company': Map<String, dynamic> company,
        'role': Map<String, dynamic> role,
        'lastLogin': String? lastLogin,
        // 'formations': List<String>? formations,
        // 'expertise': String? expertise,
      } =>
        User(
          id: id,
          name: name,
          email: email,
          phone: phone,
          isCompanyAdmin: isCompanyAdmin,
          isVerified: isVerified,
          isActive: isActive,
          logo: logo,
          bio: bio,
          clientProfile: clientProfile != null
              ? ClientProfile.fromJson(clientProfile)
              : null,
          technicianProfile: technicianProfile != null
              ? TechnicianProfile.fromJson(technicianProfile)
              : null,
          managerId: managerId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          companyId: companyId,
          company: Company.fromJson(company),
          role: Role.fromJson(role),
          roleId: Role.fromJson(role).id,
          lastLogin: lastLogin,
          // formations: formations != null ? List<String>.from(formations) : null,
          // expertise: expertise,
        ),
      _ => throw const FormatException('Invalid JSON format for User'),
    };
  }

  factory User.fromUserJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String,
      isCompanyAdmin: json['isCompanyAdmin'] != null
          ? json['isCompanyAdmin'] as bool
          : false,
      isVerified: json['isVerified'] != null
          ? json['isVerified'] as bool
          : false,
      isActive: json['isActive'] != null ? json['isActive'] as bool : false,
      logo: json['logo'] as String?,
      bio: json['bio'] as String?,
      clientProfile: json['clientProfile'] != null
          ? ClientProfile.fromJson(json['clientProfile'])
          : null,
      technicianProfile: json['technicianProfile'] != null
          ? TechnicianProfile.fromJson(json['technicianProfile'])
          : null,
      managerId: json['managerId'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      companyId: json['companyId'] as String,
      role: Role.fromJson(json['role']),
      roleId: Role.fromJson(json['role']).id,
      lastLogin: json['lastLogin'] as String?,
    );
  }

  factory User.fromUserUpdateJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      logo: json['logo'] as String?,
      updatedAt: json['updatedAt'] as String?,
      phone: json['phone'] as String,
      isCompanyAdmin: json['isCompanyAdmin'] as bool,
      isVerified: json['isVerified'] as bool,
      isActive: json['isActive'] as bool,
      clientProfile: json['clientProfile'] != null
          ? ClientProfile.fromJson(json['clientProfile'])
          : null,
      technicianProfile: json['technicianProfile'] != null
          ? TechnicianProfile.fromJson(json['technicianProfile'])
          : null,
      role: Role.fromJson(json['role']),
      lastLogin: json['lastLogin'] as String,
      companyId: json['companyId'] as String,
      createdAt: json['createdAt'] as String,
      // formations: json['formations'] != null
      //     ? List<String>.from(json['formations'])
      //     : null,
      // expertise: json['expertise'],
    );
  }

  factory User.fromJsonUpdate(Map<String, dynamic> json) {
    try {
      return User(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString(),
        phone: json['phone']?.toString() ?? '',
        isCompanyAdmin: json['isCompanyAdmin'] ?? false,
        isVerified: json['isVerified'] ?? false,
        isActive: json['isActive'] ?? true,
        logo: json['logo']?.toString(),
        bio: json['bio']?.toString(),
        createdAt: json['createdAt']?.toString() ?? '',
        updatedAt: json['updatedAt']?.toString() ?? '',
        role: Role.fromJson(json['role']),
        lastLogin: json['lastLogin']?.toString(),
        // formations: json['formations'] != null
        //     ? List<String>.from(json['formations'])
        //     : null,
        // expertise: json['expertise']?.toString(),
      );
    } catch (e) {
      throw FormatException('Invalid JSON format for User', json);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'isCompanyAdmin': isCompanyAdmin,
      'isVerified': isVerified,
      'isActive': isActive,
      'logo': logo,
      'bio': bio,
      'clientProfile': clientProfile,
      'technicianProfile': technicianProfile?.toJson(),
      'managerId': managerId,
      'createdAt': createdAt?.toString() ?? '',
      'updatedAt': updatedAt?.toString() ?? '',
      'companyId': companyId,
      'company': company?.toJson(),
      'role': role.toJson(),
      'roleId': role.id,
      'lastLogin': lastLogin,
      // 'formations': formations,
      // 'expertise': expertise,
    };
  }

  Future<Map<String, dynamic>> toUserJson(
    File? logo,
    String? password, {
    String? oldPassword,
  }) async {
    Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'isCompanyAdmin': isCompanyAdmin,
      'isVerified': isVerified,
      'isActive': isActive,
      'bio': bio,
      'managerId': managerId,
      'companyId': companyId,
      'company': company?.toJson(),
      'role': role.toRoleJson(companyId!),
      'roleId': role.id,
      'lastLogin': lastLogin,
      //   'formations': formations,
      //   'expertise': expertise,
    };

    // Gestion du mot de passe
    if (password != null && password.isNotEmpty) {
      data['password'] = password;
      if (oldPassword != null) {
        data['oldPassword'] = oldPassword;
      }
    }

    // Gestion de l'image
    if (logo != null) {
      data['logo'] = await MultipartFile.fromFile(logo.path);
    }

    // Gestion du profil technicien si le rôle est technicien
    if (role.name.toLowerCase() == 'technicien') {
      data['technicianProfile'] = {
        'expertise': technicianProfile?.expertise,
        'certifications': technicianProfile?.certifications,
        'availability':
            technicianProfile?.availability ??
            'Disponible', // Valeur par défaut
      };
    }

    return data;
  }
}

class TechnicianProfile {
  final String? id;
  final String userId;
  final String? expertise;
  final String? availability;
  final List<String> certifications;

  TechnicianProfile({
    this.id,
    required this.userId,
    this.expertise,
    this.availability,
    required this.certifications,
  });

  factory TechnicianProfile.fromJson(Map<String, dynamic> json) {
    return TechnicianProfile(
      id: json['id'],
      userId: json['userId'],
      expertise: json['expertise'],
      availability: json['availability'],
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'expertise': expertise,
      'availability': availability,
      'certifications': certifications,
    };
  }
}

class ClientProfile {
  final String id;
  final String firstName;
  final String? lastName;
  final String? email;
  final String phone;
  final String? address;
  final String? city;
  final String? clientCompany;

  ClientProfile({
    required this.id,
    required this.phone,
    required this.firstName,
    this.lastName,
    this.email,
    this.address,
    this.city,
    this.clientCompany,
  });

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      clientCompany: json['clientCompany'],
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
      'clientCompany': clientCompany,
    };
  }
}
