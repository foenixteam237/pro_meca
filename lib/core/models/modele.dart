class Modele {
  final String id;
  final String name;
  final String slug;
  final String? logo;
  final String marqueId;

  Modele({
    required this.id,
    required this.name,
    required this.slug,
    this.logo,
    required this.marqueId,
  });

  factory Modele.fromJson(Map<String, dynamic> json) {


    return Modele(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      logo: json['logo'] as String?,
      marqueId: json['marqueId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'logo': logo,
      'marqueId': marqueId,
    };
  }
}