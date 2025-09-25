class MaintenanceTask {
  String id;
  String title;
  String typeName;
  String subType;
  DateTime dateDebut;
  DateTime? dateFin;
  List<dynamic>? pieces;
  int priority;
  int costEstimate;
  int mainOeuvre;
  String? affectedToId;
  String? technician;
  String? invoiceLineId;
  String? doneById;
  String? companyId;
  bool? hasBeenOrdered;
  String? reference;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  DateTime? validatedAt;
  String visiteId;

  MaintenanceTask({
    this.id = "",
    required this.title,
    required this.typeName,
    required this.subType,
    required this.dateDebut,
    this.dateFin,
    this.pieces,
    this.doneById,
    this.companyId,
    this.hasBeenOrdered,
    this.reference,
    this.status,
    this.invoiceLineId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.validatedAt,
    required this.mainOeuvre,
    required this.priority,
    required this.costEstimate,
    this.technician,
    this.affectedToId,
    required this.visiteId,
  });

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) {
    return MaintenanceTask(
      id: json['id'] ?? "",
      title: json['title'],
      typeName: json['typeName'],
      subType: json['subTypeId'],
      hasBeenOrdered: json['hasBeenOrdered'] ?? false,
      reference: json['reference'].toString(),
      status: json['status'].toString(),
      dateDebut: DateTime.parse(json['dateDebut']),
      dateFin: json['dateFin'] != null
          ? DateTime.tryParse(json['DateFin'])
          : DateTime.tryParse("1961-01-01"),
      pieces: json['pieces'] ?? [],
      priority: json['priority'],
      doneById: json['doneById'].toString(),
      companyId: json['companyId'],
      invoiceLineId: json['invoiceLineId'].toString(),
      mainOeuvre: json['mainOeuvre'],
      costEstimate: json['costEstimate'],
      affectedToId: json['affectedToId'],
      visiteId: json['visiteId'],
      technician: json['tech'],
      createdAt: json['createAt'] != null
          ? DateTime.tryParse(json['createAt'])
          : DateTime.tryParse("1961-01-01"),
      updatedAt: json['updateAt'] != null
          ? DateTime.tryParse(json['updateAt'])
          : DateTime.tryParse("1961-01-01"),
      deletedAt: json['deleteAt'] != null
          ? DateTime.tryParse(json['deleteAt'])
          : DateTime.tryParse("1961-01-01"),
      validatedAt: json['validatedAt'] != null
          ? DateTime.tryParse(json['validatedAt'])
          : DateTime.tryParse("1961-01-01"),
    );
  }
  factory MaintenanceTask.fromVisiteJson(Map<String, dynamic> json) {
    return MaintenanceTask(
      id: json['id'] ?? "",
      title: json['title'],
      typeName: json['typeName'].toString(),
      subType: json['subTypeId'].toString(),
      hasBeenOrdered: json['hasBeenOrdered'] ?? false,
      reference: json['reference'].toString(),
      status: json['status'].toString(),
      dateDebut: DateTime.parse(json['dateDebut']),
      dateFin: json['dateFin'] != null
          ? DateTime.tryParse(json['DateFin'])
          : DateTime.tryParse("1961-01-01"),
      pieces: json['pieces'] ?? [],
      priority: json['priority'],
      doneById: json['doneById'].toString(),
      companyId: json['companyId'],
      invoiceLineId: json['invoiceLineId'].toString(),
      mainOeuvre: json['mainOeuvre'] ?? 00,
      costEstimate: json['costEstimate'] ?? 00,
      affectedToId: json['affectedToId'],
      visiteId: json['visiteId'],
      createdAt: json['createAt'] != null
          ? DateTime.tryParse(json['createAt'])
          : DateTime.tryParse("1961-01-01"),
      updatedAt: json['updateAt'] != null
          ? DateTime.tryParse(json['updateAt'])
          : DateTime.tryParse("1961-01-01"),
      deletedAt: json['deleteAt'] != null
          ? DateTime.tryParse(json['deleteAt'])
          : DateTime.tryParse("1961-01-01"),
      validatedAt: json['validatedAt'] != null
          ? DateTime.tryParse(json['validatedAt'])
          : DateTime.tryParse("1961-01-01"),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'typeName': typeName,
      'subType': subType,
      'dateDebut': dateDebut.toIso8601String(),
      'pieces': pieces,
      'priority': priority,
      'costEstimate': costEstimate,
      'mainOeuvre': mainOeuvre,
      'affectedToId': affectedToId,
      'visiteId': visiteId,
    };
  }

  /*
  MaintenanceTask copyWith({
    String? title,
    String? typeName,
    String? subType,
    DateTime? dateDebut,
    List<dynamic>? pieces,
    int? priority,
    int? costEstimate,
    String? affectedToId,
    String? visiteId,
  }) {
    return MaintenanceTask(
      title: title ?? this.title,
      typeName: typeName ?? this.typeName,
      subType: subType ?? this.subType,
      dateDebut: dateDebut ?? this.dateDebut,
      pieces: pieces ?? this.pieces,
      priority: priority ?? this.priority,
      costEstimate: costEstimate ?? this.costEstimate,
      affectedToId: affectedToId ?? this.affectedToId,
      visiteId: visiteId ?? this.visiteId,
    );
  }
*/
  @override
  String toString() {
    return 'MaintenanceTask(title: $title, typeName: $typeName, subType: $subType, dateDebut: $dateDebut, priority: $priority, costEstimate: $costEstimate, affectedToId: $affectedToId, visiteId: $visiteId, pieces: $pieces)';
  }
}

// Si vous avez un modèle Piece défini, utilisez plutôt:
class Piece {
  String pieceId;
  int quantity;
  String? name;
  double? price;

  Piece({required this.pieceId, required this.quantity, this.name, this.price});

  factory Piece.fromJson(Map<String, dynamic> json) {
    return Piece(
      pieceId: json['pieceId'],
      quantity: json['quantity'],
      name: json['name'],
      price: json['price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pieceId': pieceId,
      'quantity': quantity,
      'name': name,
      'price': price,
    };
  }
}
