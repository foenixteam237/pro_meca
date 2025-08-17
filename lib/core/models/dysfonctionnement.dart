class Dysfonctionnement {
  final String? code;
  final String detail;

  const Dysfonctionnement({
     this.code,
    required this.detail,
  });

  factory Dysfonctionnement.fromJson(Map<String, dynamic> json) {
    return Dysfonctionnement(
      code: json['code'] as String,
      detail: json['detail'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code!.isEmpty ? "NO CODE" : code,
      'detail': detail,
    };
  }
}