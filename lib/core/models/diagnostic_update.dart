import 'package:pro_meca/core/models/dysfonctionnement.dart';

class Diagnostic {
  final String id;
  final String niveauUrgence;
  final bool validated;
  final List<Dysfonctionnement> dysfonctionnements;

  const Diagnostic({
    required this.id,
    required this.niveauUrgence,
    required this.validated,
    required this.dysfonctionnements,
  });
  factory Diagnostic.fromJson(Map<String, dynamic> json) {
    return Diagnostic(
      id: json['id'].toString(),
      niveauUrgence: json['niveauUrgence'].toString(),
      validated: json['validated'] as bool,
      dysfonctionnements: (json['dysfonctionnements'] as List<dynamic>)
          .map((e) => Dysfonctionnement.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visiteId': id,
      'niveauUrgence': niveauUrgence,
      'validated': validated,
      'dysfonctionnements': dysfonctionnements.map((e) => e.toJson()).toList(),
    };
  }
}

