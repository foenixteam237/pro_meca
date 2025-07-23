import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_meca/core/models/dataLogin.dart';
import 'package:pro_meca/core/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'https://promeca.api.blasco.top';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<bool> testConnection() async {
    try {
      print("Testing connection to $_baseUrl");
      // Envoi d'une requête GET à l'endpoint de ping
      final response = await http
          .get(Uri.parse('$_baseUrl/ping'))
          .timeout(const Duration(seconds: 10));
      print("Response status code: ${response.statusCode}");
      return response.statusCode == 200 &&
          response.body.toLowerCase().contains('pong');
    } catch (e) {
      print("#########################################");
      print(e.toString());
      print("#########################################");
      // En cas d'erreur, on considère que la connexion a échoué
      return false;
    }
  }

  Future<Map<String, dynamic>> authenticateUser({
    required String identifier,
    required String password,
    required String? mail,
    bool rememberMe = false,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _headers,
      body: json.encode({
        'phone': identifier,
        'mail': mail,
        'password': password,
        'remember_me': rememberMe,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      // Conversion des données utilisateur en modèle User
      final data = Data.fromJson(responseData['data']);
      //print("Fetch data ok");
      // Vérification de la présence des tokens
      //final user = User.fromJson(responseData['data']['user']);

      print("Utilisateur connecté : ${data.user.name} (${data.user.id})");
      // Sauvegarde des tokens et de l'utilisateur
      await _saveAuthData(
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
        user: data.user,
        rememberMe: rememberMe,
      );
      print("\n Données utilisateur : ${data.user.toJson()}");
      print("Données utilisateur sauvegardées avec succès");
      return responseData;
    } else {
      print("Échec de connexion : ${response.body.toString()}");
      throw Exception('Échec de l\'authentification : ${response.body}');
    }
  }

  Future<void> _saveAuthData({
    required String accessToken,
    required String refreshToken,
    required User user,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    // Conversion du modèle User en JSON avant sauvegarde
    await prefs.setString('user_data', json.encode(user));
    await prefs.setBool('remember_me', rememberMe);

    if (!rememberMe) {
      await prefs.setBool('session_only', true);
    }
  }

  // Méthode pour récupérer l'utilisateur sauvegardé
  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    print(userData);
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  Future<User> getUserProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: {..._headers, 'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<User> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final response = await http.put(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: {..._headers, 'Authorization': 'Bearer $accessToken'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final updatedUser = User.fromJson(json.decode(response.body));

      // Mise à jour des données utilisateur sauvegardées si c'est le même utilisateur
      final currentUser = await getSavedUser();
      if (currentUser != null && currentUser.id == updatedUser.id) {
        await _saveAuthData(
          accessToken: accessToken!,
          refreshToken: prefs.getString('refreshToken')!,
          user: updatedUser,
          rememberMe: prefs.getBool('remember_me') ?? false,
        );
      }

      return updatedUser;
    } else {
      throw Exception('Failed to update profile');
    }
  }
}
