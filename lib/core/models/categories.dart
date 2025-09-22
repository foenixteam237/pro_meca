import 'package:pro_meca/core/models/pieces.dart';

class PieceCategorie {
  final String id;
  final String name;
  final String description;
  final String logo;
  final int count;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Piece>? pieces;

  PieceCategorie({
    required this.id,
    required this.name,
    required this.description,
    required this.logo,
    required this.count,
    this.createdAt,
    this.updatedAt,
    this.pieces,
  });

  factory PieceCategorie.fromJson(Map<String, dynamic> json) {
    return PieceCategorie(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'] ?? '',
      pieces: json['pieces'] == Null
          ? []
          : (json['pieces'] as List<dynamic>?)
                ?.map((pieceJson) => Piece.fromJson(pieceJson))
                .toList(),
      count: json['_count'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? ''),
      updatedAt: DateTime.parse(json['updatedAt'] ?? ''),
    );
  }
}
