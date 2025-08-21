// Modèle SubType
class SubType {
  final String id;
  final String name;
  final String typeName;
  SubType({required this.id, required this.name, required this.typeName});
  factory SubType.fromJson(Map<String, dynamic> json) {
    return SubType(
      id: json['id'] as String,
      name: json['name'] as String,
      typeName: json['typeName'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'typeName': typeName};
  }

  @override
  bool operator ==(Object other) {
    return other is SubType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Modèle InterventionType
class InterventionType {
  final String id;
  final String name;
  final String companyId;
  final List<SubType> subTypes;
  InterventionType({
    required this.id,
    required this.name,
    required this.companyId,
    required this.subTypes,
  });
  factory InterventionType.fromJson(Map<String, dynamic> json) {
    return InterventionType(
      id: json['id'] as String,
      name: json['name'] as String,
      companyId: json['companyId'] as String,
      subTypes: (json['subTypes'] as List<dynamic>)
          .map((subType) => SubType.fromJson(subType as Map<String, dynamic>))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'companyId': companyId,
      'subTypes': subTypes.map((subType) => subType.toJson()).toList(),
    };
  }

  // Méthode pour obtenir une liste de sous-types par ID
  List<SubType> getSubTypesById(String subTypeId) {
    return subTypes.where((subType) => subType.id == subTypeId).toList();
  }
}

// Classe utilitaire pour parser une liste d'InterventionTypes
class InterventionTypeHelper {
  static List<InterventionType> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => InterventionType.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
