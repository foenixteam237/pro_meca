class Piece {
  final String id;
  final String name;
  final String reference;
  final String? barcode;
  final String? logo;
  final String? sourceId;
  final String? originVehicle;
  final DateTime? recoveryDate;
  final bool isUsed;
  late final int stock;
  final int criticalStock;
  final String? location;
  final String condition;
  final int sellingPrice;
  final DateTime? purchaseDate;
  final double taxRate;
  final String categoryId;
  final String? notes;
  final List<PieceModel>? modeleCompatibles;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Category category;
  final dynamic source;
  late final bool? inStock;

  Piece({
    required this.id,
    required this.name,
    required this.reference,
    this.barcode,
    this.logo,
    this.sourceId,
    this.originVehicle,
    this.recoveryDate,
    required this.isUsed,
    required this.stock,
    required this.criticalStock,
    this.location,
    required this.condition,
    required this.sellingPrice,
    this.purchaseDate,
    required this.taxRate,
    required this.categoryId,
    this.notes,
    this.modeleCompatibles,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    this.source,
    this.inStock,
  });

  factory Piece.fromJson(Map<String, dynamic> json) {
    return Piece(
      id: json['id'],
      name: json['name'],
      reference: json['reference'],
      barcode: json['barcode'],
      logo: json['logo'] ?? "",
      sourceId: json['sourceId'],
      originVehicle: json['originVehicle'],
      recoveryDate: json['recoveryDate'] != null
          ? DateTime.parse(json['recoveryDate'])
          : null,
      isUsed: json['isUsed'],
      stock: json['stock'],
      criticalStock: json['criticalStock'],
      location: json['location'],
      condition: json['condition'],
      sellingPrice: json['sellingPrice'],
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'])
          : null,
      taxRate: json['taxRate']?.toDouble(),
      categoryId: json['categoryId'],
      notes: json['notes'],
      modeleCompatibles: (json['modeleCompatibles'] as List<dynamic>)
          .map((json) => PieceModel.fromJson(json))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      category: Category.fromJson(json['category']),
      source: json['source'],
      inStock: json['stock'] > 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'reference': reference,
      'barcode': barcode,
      'logo': logo,
      'sourceId': sourceId,
      'originVehicle': originVehicle,
      'recoveryDate': recoveryDate?.toIso8601String(),
      'isUsed': isUsed,
      'stock': stock,
      'criticalStock': criticalStock,
      'location': location,
      'condition': condition,
      'sellingPrice': sellingPrice,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'taxRate': taxRate,
      'categoryId': categoryId,
      'notes': notes,
      'modeleCompatibles': modeleCompatibles.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'category': category.toJson(),
      'source': source,
    };
  }
}

class Category {
  final String id;
  final String name;
  final String description;
  final String? logo;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.logo,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      logo: json['logo'],
    );
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description, 'logo': logo};
  }
}

class PieceModel {
  final String name;
  final String slug;

  PieceModel({required this.name, required this.slug});

  factory PieceModel.fromJson(Map<String, dynamic> json) {
    return PieceModel(name: json['name'], slug: json['slug']);
  }
  Map<String, dynamic> toJson() {
    return {'name': name, 'slug': slug};
  }
}
