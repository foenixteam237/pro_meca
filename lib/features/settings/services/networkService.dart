import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  // Vérifie l'accès réel à internet
  static Future<bool> hasInternetAccess() async {
    const timeout = Duration(seconds: 5);
    const testUrls = [
      'https://www.google.com',
      'https://www.cloudflare.com',
      'https://1.1.1.1',
    ];
    for (final url in testUrls) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(timeout);
        if (response.statusCode == 200) {
          return true; // Retourne vrai dès qu'une URL est accessible
        }
      } catch (e) {
        // Affiche l'erreur pour le débogage si nécessaire
        print('Erreur lors de l\'accès à $url: $e');
      }
    }
    return false; // Retourne faux si aucune URL n'est accessible
  }

  // Écoute les changements de connexion
  static Stream<List<ConnectivityResult>> get connectionStream {
    return Connectivity().onConnectivityChanged;
  }
}
