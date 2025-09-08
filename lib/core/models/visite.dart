import 'package:intl/intl.dart';
import 'package:pro_meca/core/models/maintenance_task.dart';
import 'package:pro_meca/core/models/photo_visite.dart';
import 'package:pro_meca/core/models/vehicle.dart';
import 'package:pro_meca/core/models/diagnostic_update.dart';

class Visite {
  final String id;
  final DateTime dateEntree;
  final DateTime? dateSortie;
  final String vehicleId;
  final String status;
  final String constatClient;
  final ElementsBords elementsBord;
  final String? companyId;
  final Vehicle? vehicle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Photo>? photos;
  final List<Diagnostic>? diagnostics;
  final List<MaintenanceTask>? intervention;

  Visite({
    required this.id,
    required this.dateEntree,
    this.dateSortie,
    this.vehicle,
    required this.vehicleId,
    required this.status,
    required this.constatClient,
    required this.elementsBord,
    this.companyId,
    this.photos,
    this.intervention,
    this.diagnostics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Visite.fromJson(Map<String, dynamic> json) {
    return Visite(
      id: json['id'].toString(),
      dateEntree: DateTime.parse(json['dateEntree'].toString()),
      dateSortie: json['dateSortie'] != null
          ? DateTime.tryParse(json['dateSortie'])
          : DateTime.tryParse("1961-01-01"),
      vehicleId: json['vehicleId'].toString(),
      status: json['status'].toString(),
      vehicle: Vehicle.fromVisiteJson(json['vehicle']),
      constatClient: json['constatClient'].toString(),
      elementsBord: ElementsBords.fromJson(
        json['elementsBord'] as Map<String, dynamic>,
      ),
      //companyId: json['companyId'].toString(),
      diagnostics: (json['diagnostics'] as List<dynamic>)
          .map((e) => Diagnostic.fromJson(e))
          .toList(),
      photos: (json['photos'] as List<dynamic>)
          .map((e) => Photo.fromJson(e))
          .toList(),
      intervention: (json['interventions'] as List<dynamic>)
          .map((e) => MaintenanceTask.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'].toString()),
      updatedAt: DateTime.parse(json['updatedAt'].toString()),
    );
  }
  factory Visite.fromVisiteJson(Map<String, dynamic> json, Vehicle vehicle) {
    return Visite(
      id: json['id'].toString(),
      dateEntree: DateTime.parse(json['dateEntree'].toString()),
      dateSortie: json['dateSortie'] != null
          ? DateTime.tryParse(json['dateSortie'].toString())
          : DateTime.tryParse("1961-01-01"),
      vehicleId: json['vehicleId'].toString(),
      status: json['status'].toString(),
      vehicle: vehicle,
      constatClient: json['constatClient'].toString(),
      elementsBord: ElementsBords.fromJson(
        json['elementsBord'] as Map<String, dynamic>,
      ),
      //companyId: json['companyId'].toString(),
      diagnostics: ((json['diagnostics'] ?? []) as List)
          .map((e) => Diagnostic.fromJson(e))
          .toList(),
      photos: ((json['photos'] ?? []) as List).map((e) => Photo.fromJson(e)).toList(),
      intervention: ((json['interventions'] ?? []) as List)
          .map((e) => MaintenanceTask.fromVisiteJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'].toString()),
      updatedAt: DateTime.parse(json['updatedAt'].toString()),
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
      'constatClient': constatClient,
      'elementsBord': elementsBord.toJson(),
      'companyId': companyId,
    };
  }

  static Map<String, int> getVehicleStatsByStatus(
    List<Visite> vehicles,
    String targetStatus,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    // Filtrer d'abord les véhicules par statut
    final filteredVehicles = vehicles
        .where((v) => v.status == targetStatus)
        .toList();

    // Compter pour aujourd'hui
    final todayCount = filteredVehicles
        .where((v) => v.updatedAt.isAfter(today))
        .length;

    // Compter pour ce mois
    final monthCount = filteredVehicles
        .where((v) => v.updatedAt.isAfter(firstDayOfMonth))
        .length;

    // Total est simplement la longueur de la liste filtrée
    final totalCount = filteredVehicles.length;

    return {'today': todayCount, 'month': monthCount, 'total': totalCount};
  }
}

/// Classe représentant les éléments à bord d'une voiture lors d'une visite.
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
    this.autres,
  });

  factory ElementsBords.fromJson(Map<String, dynamic> json) {
    return ElementsBords(
      extincteur:
          bool.tryParse(json['extincteur'].toString(), caseSensitive: false) ??
          false,
      dossier:
          bool.tryParse(json['dossier'].toString(), caseSensitive: false) ??
          false,
      cric:
          bool.tryParse(json['cric'].toString(), caseSensitive: false) ?? false,
      boitePharmacie:
          bool.tryParse(
            json['boitePharmacie'].toString(),
            caseSensitive: false,
          ) ??
          false,
      boiteOutils:
          bool.tryParse(json['boiteOutils'].toString(), caseSensitive: false) ??
          false,
      essuieGlace:
          bool.tryParse(json['essuieGlace'].toString(), caseSensitive: false) ??
          false,
      autres: json['autres'],
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
