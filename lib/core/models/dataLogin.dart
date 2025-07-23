import 'package:pro_meca/core/models/user.dart';

class Data {
  String accessToken;
  String refreshToken;
  int expiresAt;
  int refreshExpiresAt;
  User user;

  Data({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
    required this.refreshExpiresAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    //print("im there data" + json.toString());
    return switch (json) {
      {
        'accessToken': String accessToken,
        'refreshToken': String refreshToken,
        'expiresAt': int expiresAt,
        'refreshExpiresAt': int refreshExpiresAt,
        'user': Map<String, dynamic> userJson,
      } =>
        Data(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
          refreshExpiresAt: refreshExpiresAt,
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
      'refreshExpiresAt': refreshExpiresAt,
      'user': user.toJson(),
    };
  }
}
