import 'package:flutter/foundation.dart';

import 'modele.dart';

@immutable
class Brand {
  final String id;
  final String name;
  final String slug;
  final String? logoUrl;
  final List<Modele>? modeles;
  final bool isSelected;

  const Brand({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.modeles,
    this.isSelected = false,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    try {
      return Brand(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        logoUrl: json['logo']?.toString(),
        modeles: (json['modeles'] as List<dynamic>?)
            ?.map((e) => Modele.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      throw FormatException('Invalid JSON format for Brand', json);
    }
  }

  String get displayName => name.replaceAll(RegExp(r'[()]'), '');

  bool get hasLogo => logoUrl != null && logoUrl!.isNotEmpty;

  Uri? get logoUri {
    if (logoUrl == null) return null;
    try {
      return Uri.parse(logoUrl!);
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Brand &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              slug == other.slug &&
              logoUrl == other.logoUrl;

  @override
  int get hashCode => Object.hash(id, name, slug, logoUrl);

  @override
  String toString() {
    return 'Brand($id, $name, $slug, $logoUrl)';
  }


}