import 'dysfonctionnement.dart';

class Diagnostic {
  final String visiteId;
  final String niveauUrgence;
  final bool validated;
  final List<Dysfonctionnement> dysfonctionnements;

  Diagnostic({
    required this.visiteId,
    required this.niveauUrgence,
    required this.validated,
    required this.dysfonctionnements,
  });

  // Convert a Diagnostic into a Map
  Map<String, dynamic> toJson() {
    return {
      'visiteId': visiteId,
      'niveauUrgence': niveauUrgence,
      'validated': validated,
      'dysfonctionnements': dysfonctionnements.map((e) => e.toJson()).toList(),
    };
  }
  // Create a Diagnostic from a Map
  factory Diagnostic.fromMap(Map<String, dynamic> map) {
    return Diagnostic(
      visiteId: map['visiteId'] as String,
      niveauUrgence: map['niveauUrgence'] as String,
      validated: map['validated'] as bool,
      dysfonctionnements: (map['dysfonctionnements'] as List<dynamic>)
          .map((e) => Dysfonctionnement.fromJson(e))
          .toList(),
    );
  }


}