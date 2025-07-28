import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_meca/core/models/brand.dart';
import 'package:pro_meca/core/models/dataLogin.dart';
import 'package:pro_meca/core/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'https://promeca.api.blasco.top';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    return {
      ..._headers,
      'Authorization': 'Bearer $accessToken',
    };
  }

  Future<bool> _checkAndRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = prefs.getInt('expiresAt');
    final refreshExpiresAt = prefs.getInt('refreshExpiresAt');
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // 1. Vérifier si le refresh token est expiré
    if (refreshExpiresAt == null || currentTime >= refreshExpiresAt) {
      await _logoutUser();
      throw Exception('Session expirée, veuillez vous reconnecter');
    }

    // 2. Vérifier si l'access token est expiré
    if (expiresAt == null || currentTime >= expiresAt) {
      try {
        final refreshToken = prefs.getString('refreshToken');
        final response = await http.post(
          Uri.parse('$_baseUrl/auth/refresh'),
          headers: _headers,
          body: json.encode({'refreshToken': refreshToken}),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          await _saveAuthData(
            accessToken: responseData['accessToken'],
            refreshToken: responseData['refreshToken'],
            refreshExpiresAt: responseData['refreshExpiresAt'],
            expiresAt: responseData['expiresAt'],
            user: User.fromJson(responseData['user']),
            rememberMe: prefs.getBool('remember_me') ?? false,
          );
          return true;
        } else {
          await _logoutUser();
          throw Exception('Échec du rafraîchissement du token');
        }
      } catch (e) {
        await _logoutUser();
        throw Exception('Erreur lors du rafraîchissement: ${e.toString()}');
      }
    }

    return false;
  }

  Future<void> _logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Vous pouvez aussi ajouter une navigation vers l'écran de login ici
    // Ex: Navigator.pushReplacementNamed(context, '/login');
  }

  // Méthode générique pour les requêtes avec gestion automatique des tokens
  Future<http.Response> _authenticatedRequest(
      Future<http.Response> Function() requestFn,
      ) async {
    // 1. Vérifier et rafraîchir le token si nécessaire
    await _checkAndRefreshToken();

    // 2. Exécuter la requête initiale
    final response = await requestFn();

    // 3. Si le token a expiré pendant la requête, rafraîchir et réessayer
    if (response.statusCode == 401) {
      await _checkAndRefreshToken();
      return await requestFn();
    }

    return response;
  }

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
        'rememberMe': rememberMe,
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
        refreshExpiresAt: data.refreshExpiresAt,
        expiresAt: data.expiresAt,
        user: data.user,
        rememberMe: rememberMe,
      );
      return responseData;
    } else {
      print("Échec de connexion : ${response.body.toString()}");
      throw Exception('Échec de l\'authentification : ${response.body}');
    }
  }

  Future<void> _saveAuthData({
    required String accessToken,
    required String refreshToken,
    required int refreshExpiresAt,
    required int expiresAt,
    required User user,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setInt("refreshExpiresAt", refreshExpiresAt);
    await prefs.setInt("expiresAt", expiresAt);
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
          refreshExpiresAt: prefs.getInt('refreshExpiresAt')!,
          expiresAt: prefs.getInt('expiresAt')!,
          user: updatedUser,
          rememberMe: prefs.getBool('remember_me') ?? false,
        );
      }

      return updatedUser;
    } else {
      throw Exception('Failed to update profile');
    }
  }

  //Methode pour recuperer les marques
  Future<List<Brand>> getAllBrands() async {
    final response = await _authenticatedRequest(
          () async => await http.get(
        Uri.parse('$_baseUrl/brands'),
        headers: await _getAuthHeaders(),
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> brandsJson = json.decode(response.body);
      return brandsJson.map((json) => Brand.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load brands');
    }
  }
}
