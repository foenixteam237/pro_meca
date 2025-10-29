import 'package:flutter/foundation.dart' show kDebugMode;

class Report {
  final String id;
  final int version;
  final ReportContent content;
  final String status;
  final String? pdfUrl;
  final DateTime submittedAt;
  final DateTime? editableUntil;
  final String interventionId;
  final String authorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.version,
    required this.content,
    required this.status,
    this.pdfUrl,
    required this.submittedAt,
    this.editableUntil,
    required this.interventionId,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    try {
      return Report(
        id: json['id'].toString(),
        version: json['version'],
        content: ReportContent.fromJson(
          json['content'] as Map<String, dynamic>,
        ),
        status: json['status'].toString(),
        pdfUrl: json['pdfUrl'].toString(),
        submittedAt: DateTime.parse(json['submittedAt'].toString()),
        editableUntil: json['editableUntil'] != null
            ? DateTime.parse(json['editableUntil'].toString())
            : null,
        interventionId: json['interventionId'].toString(),
        authorId: json['authorId'].toString(),
        createdAt: DateTime.parse(json['createdAt'].toString()),
        updatedAt: DateTime.parse(json['updatedAt'].toString()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing Report from JSON: $e');
      }
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'content': content.toJson(),
      'status': status,
      'pdfUrl': pdfUrl,
      'submittedAt': submittedAt.toIso8601String(),
      'editableUntil': editableUntil?.toIso8601String(),
      'interventionId': interventionId,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ReportContent {
  final List<String> diagnostic;
  final List<Piece> piecesUtilisees;
  final List<String> travauxRealises;
  final int workedHours;
  final int completed;
  final List<Piece> piecesPrevues;

  ReportContent({
    required this.diagnostic,
    required this.piecesUtilisees,
    required this.travauxRealises,
    required this.workedHours,
    required this.completed,
    required this.piecesPrevues,
  });

  factory ReportContent.fromJson(Map<String, dynamic> json) {
    print(json);
    try {
      return ReportContent(
        diagnostic: (json['diagnostic'] as List<dynamic>).cast<String>(),
        piecesUtilisees: (json['pieces_utilisees'] as List<dynamic>)
            .map((e) => Piece.fromJson(e as Map<String, dynamic>))
            .toList(),
        travauxRealises: (json['travaux_realises'] as List<dynamic>)
            .cast<String>(),
        workedHours: json['workedHours'] as int,
        completed: json['completed'] as int,
        piecesPrevues: (json['pieces_prevues'] as List<dynamic>)
            .map((e) => Piece.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing ReportContent from JSON: $e');
      }
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'diagnostic': diagnostic,
      'pieces_utilisees': piecesUtilisees.map((e) => e.toJson()).toList(),
      'travaux_realises': travauxRealises,
      'workedHours': workedHours,
      'completed': completed,
      'pieces_prevues': piecesPrevues.map((e) => e.toJson()).toList(),
    };
  }
}

class Piece {
  final String reference;
  final String name;
  final int quantity;

  Piece({required this.reference, required this.name, required this.quantity});

  factory Piece.fromJson(Map<String, dynamic> json) {
    try {
      return Piece(
        reference: json['reference'].toString(),
        name: json['name'].toString(),
        quantity: json['quantity'] as int,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing Piece from JSON: $e');
      }
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'reference': reference, 'name': name, 'quantity': quantity};
  }
}
