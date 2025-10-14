// stock_movement.dart
import 'package:flutter/material.dart';
import 'package:pro_meca/core/models/facture.dart';

class StockMovement {
  String? id;
  PieceMvt piece;
  String type; // 'IN' ou 'OUT'
  int quantity;
  DateTime date;
  String? description;
  Facture? facture;
  int sellingPriceAtMovement;
  int stockAfterMovement;

  StockMovement({
    this.id,
    required this.piece,
    required this.type,
    required this.quantity,
    required this.date,
    this.description,
    this.facture,
    required this.sellingPriceAtMovement,
    required this.stockAfterMovement,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id']?.toString(),
      piece: PieceMvt.fromJson(json['piece'] ?? {}),
      type: json['type'] ?? '',
      quantity: json['quantity'] ?? 0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      description: json['description'],
      facture: json['facture'] != null
          ? Facture.fromJson(json['facture'])
          : null,
      sellingPriceAtMovement: int.tryParse(json['sellingPrice']) ?? 0,
      stockAfterMovement: json['stockAfterMovement'] ?? 0,
    );
  }

  // factory StockMovement.fromPiece(Map<String, dynamic> json) {
  //   return StockMovement(
  //     piece: PieceMvt(
  //       id: json['id']!,
  //       reference: json['reference'] ?? '',
  //       name: json['name']!,
  //       currentStock: json['stock'] as int,
  //       category: json['category']['name'] ?? '',
  //     ),
  //     type: json['type'] ?? '',
  //     quantity: 0,
  //     date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
  //     description: json['name'],
  //     facture: null,
  //     sellingPriceAtMovement: json['sellingPrice'] ?? 0,
  //     stockAfterMovement: json['stockAfterMovement'] ?? 0,
  //   );
  // }

  String get typeLabel {
    switch (type) {
      case 'IN':
        return 'Entrée';
      case 'OUT':
        return 'Sortie';
      default:
        return type;
    }
  }

  Color get typeColor {
    switch (type) {
      case 'IN':
        return Colors.green;
      case 'OUT':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class StockMovementResponse {
  final List<StockMovement> movements;
  final int totalCount;
  final bool hasMore;

  StockMovementResponse({
    required this.movements,
    required this.totalCount,
    required this.hasMore,
  });

  factory StockMovementResponse.fromJson(Map<String, dynamic> json) {
    return StockMovementResponse(
      movements: (json['movements'] as List)
          .map((item) => StockMovement.fromJson(item))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      hasMore: json['hasMore'] ?? false,
    );
  }
}

class PieceMvt {
  final String? id;
  final String name;
  final String reference;
  final String category;
  final int currentStock;

  PieceMvt({
    this.id,
    required this.name,
    required this.reference,
    required this.category,
    required this.currentStock,
  });

  factory PieceMvt.fromJson(Map<String, dynamic> json) {
    return PieceMvt(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      reference: json['reference'] ?? '',
      category: json['category']['name'] ?? '',
      currentStock: (json['stock'] ?? json['currentStock'] ?? 0) as int,
    );
  }
}
