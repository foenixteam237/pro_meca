class PieceCategorie {
  final String id;
  final String name;
  final String description;
  final String logo;
  final DateTime createdAt;
  final DateTime updatedAt;

  PieceCategorie({
    required this.id,
    required this.name,
    required this.description,
    required this.logo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PieceCategorie.fromJson(Map<String, dynamic> json) {
    return PieceCategorie(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? ''),
      updatedAt: DateTime.parse(json['updatedAt'] ?? ''),
    );
  }
}