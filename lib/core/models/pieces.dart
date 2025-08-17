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
  final DateTime createdAt;
  final DateTime updatedAt;
  final Category category;
  final dynamic source;
  late final bool? inStock ;

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
      logo: json['logo'] ?? "assets/images/logo.png",
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
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      category: Category.fromJson(json['category']),
      source: json['source'],
      inStock: json['stock'] > 0,
    );
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
}