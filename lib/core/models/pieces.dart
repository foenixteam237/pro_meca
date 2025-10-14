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
  final int? criticalStock;
  final String? location;
  final String condition;
  final int? sellingPrice;
  final DateTime? purchaseDate;
  final double? taxRate;
  final String categoryId;
  final String? notes;
  final List<PieceModel>? modeleCompatibles;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Category category;
  final PieceSource? source;
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
    this.criticalStock,
    this.location,
    required this.condition,
    this.sellingPrice,
    this.purchaseDate,
    this.taxRate,
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
      isUsed: json['isUsed'] ?? false,
      stock: json['stock'] ?? 0,
      criticalStock: json['criticalStock'],
      location: json['location'],
      condition: json['condition'] ?? 'UNKNOWN',
      sellingPrice: json['sellingPrice'],
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'])
          : null,
      taxRate: json['taxRate']?.toDouble(),
      categoryId: json['categoryId'],
      notes: json['notes'],
      modeleCompatibles: json['modeleCompatibles'] != null
          ? (json['modeleCompatibles'] as List<dynamic>)
                .map((json) => PieceModel.fromJson(json))
                .toList()
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      category: Category.fromJson(json['category']),
      source: json['source'] != null
          ? PieceSource.fromJson(json['source'])
          : null,
      inStock: (json['stock'] ?? 0) > 0,
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
      'modeleCompatibles': modeleCompatibles
          ?.map((model) => model.toJson())
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'category': category.toJson(),
      'source': source?.toJson(),
    };
  }

  static String longConditionLabel(String condition) {
    switch (condition) {
      case 'NEW':
        return 'Neuf - Jamais utilisé';
      case 'USED_GOOD':
        return 'Occasion - Excellent état';
      case 'USED_WORN':
        return 'Occasion - Usure normale';
      case 'USED_DAMAGED':
        return 'Occasion - À réparer';
      case 'UNKNOWN':
        return 'État non vérifié';
      default:
        return condition;
    }
  }

  static String shortConditionLabel(String condition) {
    switch (condition) {
      case 'NEW':
        return 'NEUF';
      case 'USED_GOOD':
        return 'EXCELLENT';
      case 'USED_WORN':
        return 'NORMAL';
      case 'USED_DAMAGED':
        return 'À RÉPARER';
      case 'UNKNOWN':
        return 'NON VÉRIFIÉ';
      default:
        return condition.toUpperCase();
    }
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
  final String id;
  final String name;
  final String slug;
  final String? marque;
  // final int? yearStart;
  // final int? yearEnd;

  PieceModel({
    required this.id,
    required this.name,
    required this.slug,
    this.marque,
    // this.yearStart,
    // this.yearEnd,
  });

  factory PieceModel.fromJson(Map<String, dynamic> json) {
    return PieceModel(
      id: json['id'] ?? json['_id'],
      name: json['name'],
      slug: json['slug'],
      marque: json['marque'],
      // yearStart: json['yearStart'],
      // yearEnd: json['yearEnd'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'marque': marque,
      // 'yearStart': yearStart,
      // 'yearEnd': yearEnd,
    };
  }

  String get displayName {
    // if (marque != null && yearStart != null) {
    //   return '$marque $name ($yearStart${yearEnd != null ? '-$yearEnd' : ''})';
    // }
    if (marque != null) {
      return '$marque $name';
    }
    return name;
  }
}

class PieceSource {
  final String? id;
  final String? type;
  final String? contactName;
  final String? phone;
  final String? location;
  final String? notes;
  final DateTime? createdAt;

  PieceSource({
    this.id,
    this.type,
    this.contactName,
    this.phone,
    this.location,
    this.notes,
    this.createdAt,
  });

  factory PieceSource.fromJson(Map<String, dynamic> json) {
    return PieceSource(
      id: json['id'],
      type: json['type'],
      contactName: json['contactName'],
      phone: json['phone'],
      location: json['location'],
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'contactName': contactName,
      'phone': phone,
      'location': location,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
