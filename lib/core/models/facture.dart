import 'dart:ui';

import 'package:flutter/material.dart';

class FactureResponse {
  final List<Facture> factures;
  final int totalCount;
  final bool hasMore;

  FactureResponse({
    required this.factures,
    required this.totalCount,
    required this.hasMore,
  });

  factory FactureResponse.fromJson(Map<String, dynamic> json) {
    return FactureResponse(
      factures: (json['factures'] as List)
          .map((item) => Facture.fromJson(item))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      hasMore: json['hasMore'] ?? false,
    );
  }
}

class Facture {
  final String id;
  final String reference;
  final DateTime date;
  final DateTime? dueDate;
  final double totalHT;
  final double totalTTC;
  final String status;
  final Client client;
  final Visite visite;
  final List<InvoiceLine> lines;
  final String? notes;
  final String? totalTTCWord;
  final String? totalHTWord;
  final bool includeTVA;
  final bool includeIR;
  final double tvaRate; // Taux de TVA (19.25)
  final double irRate; // Taux d'IR (5.5)

  Facture({
    required this.id,
    required this.reference,
    required this.date,
    this.dueDate,
    required this.totalHT,
    required this.totalTTC,
    required this.status,
    required this.client,
    required this.visite,
    required this.lines,
    this.notes,
    this.totalTTCWord,
    this.totalHTWord,
    this.includeTVA = true, // Par défaut avec TVA
    this.includeIR = false, // Par défaut sans IR
    this.tvaRate = 19.25,
    this.irRate = 5.5,
  });

  // Gestion robuste des nombres (Decimal, num, String)
  static double _parseDecimal(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      totalHT: _parseDecimal(json['totalHT']),
      totalTTC: _parseDecimal(json['totalTTC']),
      status: json['status'] ?? 'DRAFT',
      client: Client.fromJson(json['client'] ?? {}),
      visite: Visite.fromJson(json['visite'] ?? {}),
      lines: (json['lines'] as List? ?? [])
          .map((item) => InvoiceLine.fromJson(item))
          .toList(),
      notes: json['notes'],
      totalHTWord: json['totalHTWord'],
      totalTTCWord: json['totalTTCWord'],
      includeTVA: json['includeTVA'] ?? true,
      includeIR: json['includeIR'] ?? false,
      tvaRate: _parseDecimal(json['tvaRate'] ?? 19.25),
      irRate: _parseDecimal(json['irRate'] ?? 5.5),
    );
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'DRAFT':
        return 'Proforma';
      case 'OK':
        return 'Validée';
      case 'SENT':
        return 'Envoyée';
      case 'PARTIAL':
        return 'Partiellement payée';
      case 'PAID':
        return 'Payée';
      case 'OVERDUE':
        return 'En retard';
      case 'CANCELLED':
        return 'Annulée';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'DRAFT':
        return Colors.orange;
      case 'OK':
        return Colors.green;
      case 'SENT':
        return Colors.blue;
      case 'PARTIAL':
        return Colors.amber;
      case 'PAID':
        return Colors.green;
      case 'OVERDUE':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class Client {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;

  Client({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'],
      phone: json['phone'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class Visite {
  final String id;
  final Vehicle vehicle;

  Visite({required this.id, required this.vehicle});

  factory Visite.fromJson(Map<String, dynamic> json) {
    return Visite(
      id: json['id'] ?? '',
      vehicle: Vehicle.fromJson(json['vehicle'] ?? {}),
    );
  }
}

class Vehicle {
  final String licensePlate;
  final String? chassis;
  final String? marque;
  final String? model;

  Vehicle({required this.licensePlate, this.chassis, this.marque, this.model});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      licensePlate: json['licensePlate'],
      chassis: json['chassis'],
      marque: json['marque'] is Map ? json['marque']['name'] : json['marque'],
      model: json['model'] is Map ? json['model']['name'] : json['model'],
    );
  }
}

class InvoiceLine {
  final String id;
  final String description;
  final double quantity;
  final double unitPrice;
  final double totalHT;
  final double totalTTC;
  final String? interventionId;

  InvoiceLine({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalHT,
    required this.totalTTC,
    this.interventionId,
  });

  factory InvoiceLine.fromJson(Map<String, dynamic> json) {
    double parseDecimal(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return InvoiceLine(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      quantity: parseDecimal(json['quantity']),
      unitPrice: parseDecimal(json['unitPrice']),
      totalHT: parseDecimal(json['totalHT']),
      totalTTC: parseDecimal(json['totalTTC']),
      interventionId: json['interventionId'],
    );
  }
}
