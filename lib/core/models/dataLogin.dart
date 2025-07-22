import 'package:pro_meca/core/models/user.dart';

class Data {
  String accessToken;
  String refreshToken;
  String expiresAt;
  User user;

  Data({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'accessToken': String accessToken,
        'refreshToken': String refreshToken,
        'expiresAt': String expiresAt,
        'user': Map<String, dynamic> userJson,
      } =>
        Data(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
          user: User.fromJson(userJson),
        ),
      _ => throw Exception('Invalid JSON format for Data'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshTtoken': refreshToken,
      'expiresAt': expiresAt,
      'user': user?.toJson(),
    };
  }
}
