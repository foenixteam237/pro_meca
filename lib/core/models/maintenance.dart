
import 'package:pro_meca/core/models/maintenance_task.dart';

class Maintenance {
  List<MaintenanceTask> maintenance;
  String visiteId;
  String diagId;
  bool replaceExisting;

  Maintenance({
    required this.diagId,
    required this.maintenance,
    required this.replaceExisting,
    required this.visiteId,
  });

  factory Maintenance.fromJson(Map<String, dynamic> json) {
    return Maintenance(
      diagId: json['diagId'],
      maintenance: (json['interventions'] as List<dynamic>)
          .map((task) => MaintenanceTask.fromJson(task as Map<String, dynamic>))
          .toList(),
      replaceExisting: json['replaceExisting'],
      visiteId: json['visiteId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diagId': diagId,
      'interventions': maintenance.map((task) => task.toJson()).toList(),
      'replaceExisting': replaceExisting,
      'visiteId': visiteId,
    };
  }

}

