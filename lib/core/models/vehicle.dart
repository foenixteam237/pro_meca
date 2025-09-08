import 'dart:io';

import 'package:dio/dio.dart';

import 'client.dart';

class Vehicle {
  final String? id;
  final String marqueId;
  final String modelId;
  final int year;
  final String chassis;
  final String licensePlate;
  final String color;
  final String? logo;
  final int kilometrage;
  final String clientId;
  final String companyId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Client? client;

  Vehicle({
    this.id,
    required this.marqueId,
    required this.modelId,
    required this.year,
    required this.chassis,
    required this.licensePlate,
    required this.color,
    this.logo,
    required this.kilometrage,
    required this.clientId,
    required this.companyId,
    this.createdAt,
    this.updatedAt,
    this.client,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    //print(json);
    return Vehicle(
      id: json['id'].toString(),
      marqueId: json['marqueId'] ?? "",
      modelId: json['modelId'] ?? "",
      year: json['year'] ?? 00000,
      chassis: json['chassis'].toString(),
      licensePlate: json['licensePlate'].toString(),
      color: json['color'] ?? "NO DEFINE",
      logo:
          json['logo'] ??
          "https://promeca.api.blasco.top/logo/vehicle/6886b12681f36a0.png",
      kilometrage: json['kilometrage'] ?? 00000,
      clientId: json['clientId'].toString(),
      companyId: json['companyId'] ?? "",
      createdAt: DateTime.parse(json['createdAt'].toString()),
      updatedAt: DateTime.parse(json['updatedAt'].toString()),
      client: Client.fromJsn(json['client'] as Map<String, dynamic>),
    );
  }

  factory Vehicle.fromVisiteJson(Map<String, dynamic> json) {
    print(json['marque']["id"] );
    return Vehicle(
      id: json['id'].toString(),
      marqueId: json['marque']["id"] ?? "",
      modelId: json['model'] ["id"]?? "",
      year: json['year'] ?? 00000,
      chassis: json['chassis'].toString(),
      licensePlate: json['licensePlate'].toString(),
      color: json['color'] ?? "NO DEFINE",
      logo:
      json['logo'] ??
          "https://promeca.api.blasco.top/logo/vehicle/6886b12681f36a0.png",
      kilometrage: json['kilometrage'] ?? 00000,
      clientId: json['clientId'].toString(),
      companyId: json['companyId'] ?? "",
      createdAt: DateTime.parse(json['createdAt'].toString()),
      updatedAt: DateTime.parse(json['updatedAt'].toString()),
      client: Client.fromJsn(json['client'] as Map<String, dynamic>),
    );
  }
  Future<Map<String, dynamic>> toJson(File? logo) async {
    return {
      'marqueId': marqueId,
      'modelId': modelId,
      'year': year,
      'chassis': chassis,
      'licensePlate': licensePlate,
      'color': color,
      'kilometrage': kilometrage,
      'clientId': clientId,
      'companyId': companyId,
      'logo': logo != null ? await MultipartFile.fromFile(logo.path) : null,
      'createdAt': DateTime.now().toIso8601String().toString(),
      //'updatedAt': updatedAt?.toIso8601String(),
      //'client': client?.toJson(),
    };
  }
}
