import 'package:intl/intl.dart';
import 'package:pro_meca/core/models/vehicle.dart';

class Visite {
  final String id;
  final DateTime dateEntree;
  final DateTime? dateSortie;
  final String vehicleId;
  final String status;
  final String constatClient;
  final ElementsBord elementsBord;
  final String companyId;
  final Vehicle? vehicle;
  final DateTime createdAt;
  final DateTime updatedAt;

  Visite({
    required this.id,
    required this.dateEntree,
    this.dateSortie,
    this.vehicle,
    required this.vehicleId,
    required this.status,
    required this.constatClient,
    required this.elementsBord,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Visite.fromJson(Map<String, dynamic> json) {
    return Visite(
      id: json['id'] as String,
      dateEntree: DateTime.parse(json['dateEntree'] as String),
      dateSortie: json['dateSortie'] != null
          ? DateTime.tryParse(json['dateSortie'])
          : null,
      vehicleId: json['vehicleId'] as String,
      status: json['status'] as String,
      vehicle: json['vehicle'],
      constatClient: json['constatClient'] as String,
      elementsBord: ElementsBord.fromJson(
        json['elementsBord'] as Map<String, dynamic>,
      ),
      companyId: json['companyId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {

    DateTime nowUtc = dateEntree;
    DateTime camerounDate = nowUtc.add(const Duration(hours: 1)); // GMT+1

    String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss+01:00').format(camerounDate);
    return {
      'dateEntree': formattedDate,
      'vehicleId': vehicleId,
      'status': status,
      'constatClient': constatClient,
      'elementsBord': elementsBord.toJson(),
      'companyId': companyId,
    };
  }
}

/// Classe représentant les éléments à bord d'une voiture lors d'une visite.
class ElementsBord {
  final bool extincteur;
  final bool dossier;
  final bool cric;
  final bool boitePharmacie;
  final bool boiteOutils;
  final bool essuieGlace;

  ElementsBord({
    required this.extincteur,
    required this.dossier,
    required this.cric,
    required this.boitePharmacie,
    required this.boiteOutils,
    required this.essuieGlace,
  });

  factory ElementsBord.fromJson(Map<String, dynamic> json) {
    return ElementsBord(
      extincteur: json['extincteur'] as bool? ?? false,
      dossier: json['dossier'] as bool? ?? false,
      cric: json['cric'] as bool? ?? false,
      boitePharmacie: json['boitePharmacie'] as bool? ?? false,
      boiteOutils: json['boiteOutils'] as bool? ?? false,
      essuieGlace: json['essuie-glace'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extincteur': extincteur,
      'dossier': dossier,
      'cric': cric,
      'boitePharmacie': boitePharmacie,
      'boiteOutils': boiteOutils,
      'essuie-glace': essuieGlace,
    };
  }
}
