import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  // Vérifie l'accès réel à internet
  //**
  //
  // */
  static Future<bool> hasInternetAccess() async {
    //if (!await hasNetworkConnection()) return false;

    try {
      const timeout = Duration(seconds: 5);
      const testUrls = [
        'https://www.google.com',
        'https://www.cloudflare.com',
        'https://1.1.1.1',
      ];

      for (final url in testUrls) {
        try {
          final response = await http.get(Uri.parse(url)).timeout(timeout);
          if (response.statusCode == 200) return true;
        } catch (_) {
          continue;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // Écoute les changements de connexion
  static Stream<List<ConnectivityResult>> get connectionStream {
    return Connectivity().onConnectivityChanged;
  }
}
