import 'package:intl/intl.dart';
import 'package:pro_meca/core/models/photo_visite.dart';
import 'package:pro_meca/core/models/diagnostic_update.dart';
import 'package:pro_meca/core/models/vehicle.dart';

class Visites {
  final String id;
  final DateTime dateEntree;
  final DateTime? dateSortie;
  final String vehicleId;
  final String status;
  final String constatClient;
  final ElementsBords elementsBord;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Vehicle? vehicle;
  final List<Photo>? photos;
  final List<Diagnostic> diagnostics;

  const Visites({
    required this.id,
    required this.dateEntree,
    required this.dateSortie,
    required this.vehicleId,
    required this.status,
    required this.constatClient,
    required this.elementsBord,
    required this.createdAt,
    required this.updatedAt,
    this.vehicle,
    this.photos,
    required this.diagnostics,
  });

  factory Visites.fromJson(Map<String, dynamic> json) {
    return Visites(
      id: json['id'] as String,
      dateEntree: DateTime.parse(json['dateEntree'] as String),
      dateSortie: json['dateSortie'] != null ? DateTime.parse(json['dateSortie']) : null,
      vehicleId: json['vehicleId'] as String,
      status: json['status'] as String,
      constatClient: json['constatClient'] as String,
      vehicle: json['vehicle'],
      elementsBord: ElementsBords.fromJson(json['elementsBord']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      photos: (json['photos'] as List<dynamic>)
          .map((e) => Photo.fromJson(e))
          .toList(),
      diagnostics: (json['diagnostics'] as List<dynamic>)
          .map((e) => Diagnostic.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    DateTime nowUtc = dateEntree;
    DateTime camerounDate = nowUtc.add(const Duration(hours: 1)); // GMT+1

    String formattedDate = DateFormat(
      'yyyy-MM-ddTHH:mm:ss+01:00',
    ).format(camerounDate);
    return {
      'dateEntree': formattedDate,
      'vehicleId': vehicleId,
      //'status': status,
      'constatClient': constatClient,
      'elementsBord': elementsBord.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ElementsBords {
  final bool extincteur;
  final bool dossier;
  final bool cric;
  final bool boitePharmacie;
  final bool boiteOutils;
  final bool essuieGlace;
  final String? autres;

  const ElementsBords({
    required this.extincteur,
    required this.dossier,
    required this.cric,
    required this.boitePharmacie,
    required this.boiteOutils,
    required this.essuieGlace,
    this.autres
  });

  factory ElementsBords.fromJson(Map<String, dynamic> json) {
    return ElementsBords(
      extincteur: json['extincteur'] as bool,
      dossier: json['dossier'] as bool,
      cric: json['cric'] as bool,
      boitePharmacie: json['boitePharmacie'] as bool,
      boiteOutils: json['boiteOutils'] as bool,
      essuieGlace: json['essuie-glace'] as bool,
      autres: json['autres'] as String,
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
      'autres': autres,
    };
  }
}
