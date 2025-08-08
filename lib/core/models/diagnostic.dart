class Diagnostic {
  final String visiteId;
  final String problemReported;
  final String problemIdentified;
  final String errorCode;
  final String urgencyLevel;

  Diagnostic({
    required this.visiteId,
    required this.problemReported,
    required this.problemIdentified,
    required this.errorCode,
    required this.urgencyLevel,
  });

  // Convert a Diagnostic into a Map
  Map<String, dynamic> toMap() {
    return {
      'visiteId': visiteId,
      'constatClient': problemReported,
      'note': problemIdentified,
      'codeErreur': errorCode,
      'niveauUrgence': urgencyLevel,
    };
  }

  // Create a Diagnostic from a Map
  factory Diagnostic.fromMap(Map<String, dynamic> map) {
    return Diagnostic(
      visiteId: map['visiteId'] as String,
      problemReported: map['constatClient'] as String,
      problemIdentified: map['note'] as String,
      errorCode: map['codeErreur'] as String,
      urgencyLevel: map['niveauUrgence'] as String,
    );
  }

  // Optionally, you can add a copyWith method for immutability
  Diagnostic copyWith({
    String? visiteId,
    String? problemReported,
    String? problemIdentified,
    String? errorCode,
    String? urgencyLevel,
  }) {
    return Diagnostic(
      visiteId: visiteId ?? this.visiteId,
      problemReported: problemReported ?? this.problemReported,
      problemIdentified: problemIdentified ?? this.problemIdentified,
      errorCode: errorCode ?? this.errorCode,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
    );
  }

  // Override toString for better debugging
  @override
  String toString() {
    return 'Diagnostic(visiteId: $visiteId, problemReported: $problemReported, '
        'problemIdentified: $problemIdentified, errorCode: $errorCode, '
        'urgencyLevel: $urgencyLevel)';
  }

  // Override equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Diagnostic &&
        other.visiteId == visiteId &&
        other.problemReported == problemReported &&
        other.problemIdentified == problemIdentified &&
        other.errorCode == errorCode &&
        other.urgencyLevel == urgencyLevel;
  }

  @override
  int get hashCode {
    return visiteId.hashCode ^
    problemReported.hashCode ^
    problemIdentified.hashCode ^
    errorCode.hashCode ^
    urgencyLevel.hashCode;
  }
}