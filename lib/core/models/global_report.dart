class GlobalReport {
  final Visite visite;
  final Vehicle vehicle;
  final Client client;
  final List<Intervention> interventions;
  final Resume resume;

  GlobalReport({
    required this.visite,
    required this.vehicle,
    required this.client,
    required this.interventions,
    required this.resume,
  });

  factory GlobalReport.fromJson(Map<String, dynamic> json) {
    return GlobalReport(
      visite: Visite.fromJson(json['visite']),
      vehicle: Vehicle.fromJson(json['vehicle']),
      client: Client.fromJson(json['client']),
      interventions: (json['interventions'] as List)
          .map((i) => Intervention.fromJson(i))
          .toList(),
      resume: Resume.fromJson(json['resume']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visite': visite.toJson(),
      'vehicle': vehicle.toJson(),
      'client': client.toJson(),
      'interventions': interventions.map((i) => i.toJson()).toList(),
      'resume': resume.toJson(),
    };
  }
}

class Visite {
  final String id;
  final String dateEntree;
  final String dateSortie;
  final String status;

  Visite({
    required this.id,
    required this.dateEntree,
    required this.dateSortie,
    required this.status,
  });

  factory Visite.fromJson(Map<String, dynamic> json) {
    return Visite(
      id: json['id'],
      dateEntree: json['dateEntree'],
      dateSortie: json['dateSortie'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateEntree': dateEntree,
      'dateSortie': dateSortie,
      'status': status,
    };
  }
}

class Vehicle {
  final String? licensePlate;
  final String chassis;
  final String marque;
  final String model;
  final int? year;

  Vehicle({
    this.licensePlate,
    required this.chassis,
    required this.marque,
    required this.model,
    this.year,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      licensePlate: json['licensePlate']?.toString() ?? '',
      chassis: json['chassis'],
      marque: json['marque'],
      model: json['model'],
      year: json['year'] ?? 00,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'licensePlate': licensePlate,
      'chassis': chassis,
      'marque': marque,
      'model': model,
      'year': year,
    };
  }
}

class Client {
  final String name;
  final String email;
  final String phone;

  Client({required this.name, required this.email, required this.phone});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'phone': phone};
  }
}

class Intervention {
  final String id;
  final String reference;
  final String type;
  final String subType;
  final String title;
  final String status;
  final String technicien;
  final String dateDebut;
  final String dateFin;
  final int mainOeuvre;
  final String diagnostic;
  final List<String> travauxRealises;
  final List<Piece> piecesUtilisees;
  final double workedHours;
  final int completed;
  final List<Piece> piecesPrevue;

  Intervention({
    required this.id,
    required this.reference,
    required this.type,
    required this.subType,
    required this.title,
    required this.status,
    required this.technicien,
    required this.dateDebut,
    required this.dateFin,
    required this.mainOeuvre,
    required this.diagnostic,
    required this.travauxRealises,
    required this.piecesUtilisees,
    required this.workedHours,
    required this.completed,
    required this.piecesPrevue,
  });

  factory Intervention.fromJson(Map<String, dynamic> json) {
    return Intervention(
      id: json['id'],
      reference: json['reference'],
      type: json['type'],
      subType: json['subType'],
      title: json['title'],
      status: json['status'],
      technicien: json['technicien'],
      dateDebut: json['dateDebut'],
      dateFin: json['dateFin'],
      mainOeuvre: json['mainOeuvre'],
      diagnostic: json['diagnostic'],
      travauxRealises: List<String>.from(json['travauxRealises']),
      piecesUtilisees: List<Piece>.from(json['piecesUtilisees']),
      workedHours: json['workedHours'].toDouble(),
      completed: json['completed'],
      piecesPrevue: (json['piecesPrevue'] as List)
          .map((p) => Piece.fromJson(p))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'type': type,
      'subType': subType,
      'title': title,
      'status': status,
      'technicien': technicien,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'mainOeuvre': mainOeuvre,
      'diagnostic': diagnostic,
      'travauxRealises': travauxRealises,
      'piecesUtilisees': piecesUtilisees,
      'workedHours': workedHours,
      'completed': completed,
      'piecesPrevue': piecesPrevue.map((p) => p.toJson()).toList(),
    };
  }
}

class Piece {
  final String reference;
  final String name;
  final int quantity;

  Piece({required this.reference, required this.name, required this.quantity});

  factory Piece.fromJson(Map<String, dynamic> json) {
    return Piece(
      reference: json['reference'],
      name: json['name'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'reference': reference, 'name': name, 'quantity': quantity};
  }
}

class Resume {
  final int totalInterventions;
  final int interventionsValidees;
  final double totalHeuresTravail;
  final int totalMainOeuvre;

  Resume({
    required this.totalInterventions,
    required this.interventionsValidees,
    required this.totalHeuresTravail,
    required this.totalMainOeuvre,
  });

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      totalInterventions: json['totalInterventions'],
      interventionsValidees: json['interventionsValidees'],
      totalHeuresTravail: json['totalHeuresTravail'].toDouble(),
      totalMainOeuvre: json['totalMainOeuvre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalInterventions': totalInterventions,
      'interventionsValidees': interventionsValidees,
      'totalHeuresTravail': totalHeuresTravail,
      'totalMainOeuvre': totalMainOeuvre,
    };
  }
}
