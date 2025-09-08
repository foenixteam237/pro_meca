class Photo {
  final String logo;
  final bool isMain;
  final int position;

  const Photo({
    required this.logo,
    required this.isMain,
    required this.position,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      logo: json['logo'].toString(),
      isMain: json['isMain'] as bool,
      position: json['position'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'logo': logo, 'isMain': isMain, 'position': position};
  }
}
