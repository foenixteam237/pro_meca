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
    return Vehicle(
      id: json['id'] as String,
      marqueId: json['marqueId'] as String,
      modelId: json['modelId'] as String,
      year: json['year'] as int,
      chassis: json['chassis'] as String,
      licensePlate: json['licensePlate'] as String,
      color: json['color'] as String,
      logo: json['logo'] as String?,
      kilometrage: json['kilometrage'] as int,
      clientId: json['clientId'] as String,
      companyId: json['companyId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      client: Client.fromJson(json['client'] as Map<String, dynamic>),
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
      'logo': logo != null
    ? await MultipartFile.fromFile(logo.path)
    : null,
      'createdAt': DateTime.now().toIso8601String().toString(),
      //'updatedAt': updatedAt?.toIso8601String(),
      //'client': client?.toJson(),
    };
  }
}
