
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pro_meca/services/dio_api_services.dart';

import '../../../models/pieces.dart';
import '../../../models/categories.dart';

class PiecesService {
  final Dio _dio;

  PiecesService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiDioService().apiUrl,
          contentType: 'application/json',
          responseType: ResponseType.json,
        ),
      );

  /// Récupérer la liste des pièces
  Future<List<Piece>> fetchPieces(
    BuildContext context,
    String categoryId,
  ) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/pieces/category/$categoryId',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] ?? response.data['pieces'] ?? []);

        // Convertit chaque élément JSON en objet Piece
        return data.map((json) => Piece.fromJson(json)).toList();
      } else {
        debugPrint(
          "Erreur lors de la récupération des pièces: ${response.statusCode}",
        );
        return [];
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? e.message ?? 'Erreur inconnue';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Impossible de récupérer les pièces. $errorMessage"),
        ),
      );
      debugPrint('Erreur Dio: ${e.response?.statusCode}: ${e.response?.data}');
      return [];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur inattendue: ${e.toString()}")),
      );
      debugPrint('Erreur: ${e.toString()}');
      return [];
    }
  }

  /// Récupérer la liste des modèles de véhicules
  Future<List<PieceModel>> fetchVehicleModels(
    BuildContext context, {
    String? searchQuery,
    String? marque,
    int? limit = 50,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (searchQuery != null) queryParams['search'] = searchQuery;
      if (marque != null) queryParams['marque'] = marque;
      if (limit != null) queryParams['limit'] = limit;

      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/models/vehicles',
          queryParameters: queryParams,
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] ?? response.data['models'] ?? []);

        return data.map((json) => PieceModel.fromJson(json)).toList();
      } else {
        debugPrint(
          "Erreur lors de la récupération des modèles: ${response.statusCode}",
        );
        return [];
      }
    } on DioException catch (e) {
      debugPrint(
        'Erreur récupération modèles: ${e.response?.statusCode}: ${e.response?.data}',
      );
      return [];
    } catch (e) {
      debugPrint('Erreur inattendue modèles: ${e.toString()}');
      return [];
    }
  }

  /// Récupérer le nombre de catégories
  Future<Map<String, int>> getCategoryPieceCount(BuildContext context) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/pieces/cat-pie-count',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        debugPrint("cat_pie = $data");
        final catCount = data['cat'] as int? ?? -1;
        final pieCount = data['pie'] as int? ?? -1;
        final invValue = data['inv'] as int? ?? -1;

        return {'cat': catCount, 'pie': pieCount, 'inv': invValue};
      } else {
        throw Exception('Type de réponse inattendu: ${data.runtimeType}');
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? e.message ?? 'Erreur inconnue';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible de récupérer les statistiques: $errorMessage",
          ),
        ),
      );
      debugPrint('Erreur Dio: ${e.response?.statusCode}: ${e.response?.data}');
      return {'cat': -1, 'pie': -1, 'inv': -1};
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Statistiques indisponibles")));
      debugPrint('Erreur: ${e.toString()}');
      return {'cat': -1, 'pie': -1, 'inv': -1};
    }
  }

  /// Récupérer les stocks critiques
  Future<List<PieceCritical>> getCriticalStock(BuildContext context) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.get(
          '/pieces/critical/stock',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data;
        debugPrint(data.toString());

        return data.map((json) => PieceCritical.fromJson(json)).toList();
      } else {
        debugPrint(
          "Erreur lors de la récupération des stocks critiques: ${response.statusCode}",
        );
        return [];
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? e.message ?? 'Erreur inconnue';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible de récupérer les stocks critiques. $errorMessage",
          ),
        ),
      );
      debugPrint('Erreur Dio: ${e.response?.statusCode}: ${e.response?.data}');
      return [];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur inattendue: ${e.toString()}")),
      );
      debugPrint('Erreur: ${e.toString()}');
      return [];
    }
  }

  /// Ajouter une nouvelle pièce
  Future<bool> addPiece(FormData pieceData, BuildContext context) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.post(
          '/pieces/create',
          data: pieceData,
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );
      debugPrint(response.data.toString());
      return response.statusCode == 201;
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible d'ajouter la pièce. ${e.response?.data['message'] ?? e.message}",
          ),
        ),
      );
      debugPrint('Erreur Dio: ${e.response?.statusCode}: ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('Erreur: ${e.toString()}');
      return false;
    }
  }

  /// Mettre à jour une pièce existante
  Future<bool> updatePiece(
    String pieceId,
    FormData pieceData,
    BuildContext context,
  ) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.put(
          '/pieces/$pieceId',
          data: pieceData,
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );
      return response.statusCode == 201;
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible de modifier la pièce. ${e.response?.data['message'] ?? e.message}",
          ),
        ),
      );
      debugPrint('Erreur Dio: ${e.response?.statusCode}: ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('Erreur: ${e.toString()}');
      return false;
    }
  }

  /// Supprimer une pièce
  Future<bool> deletePiece(String pieceId, BuildContext context) async {
    try {
      final response = await ApiDioService().authenticatedRequest(
        () async => await _dio.delete(
          '/pieces/$pieceId',
          options: Options(headers: await ApiDioService().getAuthHeaders()),
        ),
      );
      return response.statusCode == 204;
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible de supprimer la pièce. ${e.response?.data['message'] ?? e.message}",
          ),
        ),
      );
      debugPrint('Erreur Dio: ${e.response?.statusCode}: ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('Erreur: ${e.toString()}');
      return false;
    }
  }

  Future<List<PieceCategorie>> fetchPieceCategories(
    BuildContext context,
  ) async {
    try {
      final headers = await ApiDioService().getAuthHeaders();

      final response = await ApiDioService().authenticatedRequest(
        () => _dio.get('/categories', options: Options(headers: headers)),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data;
        debugPrint(data.toString());
        return data.map((json) => PieceCategorie.fromJson(json)).toList();
      } else {
        debugPrint(
          "Erreur lors de la récupération des catégories de pièces: code ${response.statusCode}",
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur serveur inattendue")),
        );
        return [];
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible de récupérer les catégories : $errorMessage",
          ),
        ),
      );
      debugPrint('Erreur Dio: ${e.response?.statusCode}: ${e.response?.data}');
      return [];
    } catch (e, stack) {
      debugPrint('Erreur inconnue: $e');
      debugPrint('StackTrace: $stack');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur inattendue lors de la récupération."),
        ),
      );
      return [];
    }
  }

  Future<List<PieceCategorie>> fetchCategorieWithPieces(
    BuildContext context,
  ) async {
    try {
      // Récupère les catégories simples
      final headers = await ApiDioService().getAuthHeaders();

      final response = await ApiDioService().authenticatedRequest(
        () => _dio.get('/categories', options: Options(headers: headers)),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> rawCategories = response.data;

        List<PieceCategorie> categories = [];

        for (final jsonCat in rawCategories) {
          try {
            // Récupérer les pièces de cette catégorie
            final String categoryId = jsonCat['id'].toString();
            final pieces = await fetchPieces(context, categoryId);
            // Fusionner les données en injectant "pieces"
            final enrichedJson = Map<String, dynamic>.from(jsonCat)
              ..['pieces'] = pieces.map((p) => p.toJson()).toList();
            // Construire la catégorie complète
            categories.add(PieceCategorie.fromJson(enrichedJson));
          } catch (e) {
            debugPrint("Erreur lors de l'enrichissement de la catégorie: $e");
          }
        }

        return categories;
      } else {
        debugPrint(
          "Erreur lors de la récupération des catégories: code ${response.statusCode}",
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur serveur inattendue")),
        );
        return [];
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible de récupérer les catégories : $errorMessage",
          ),
        ),
      );
      debugPrint('Erreur Dio: ${e.response?.statusCode}: ${e.response?.data}');
      return [];
    } catch (e, stack) {
      debugPrint('Erreur inconnue: $e');
      debugPrint('StackTrace: $stack');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur inattendue lors de la récupération."),
        ),
      );
      return [];
    }
  }

  /// Retourne la référence disponible pour le [name].
  /// Lève une exception si le serveur renvoie une erreur.
  Future<String> getNextReference(String name) async {
    final response = await ApiDioService().authenticatedRequest(
      () async => await _dio.get(
        '/pieces/next/reference',
        queryParameters: {'name': name},
        options: Options(headers: await ApiDioService().getAuthHeaders()),
      ),
    );

    // Le serveur renvoie { "reference": "ALTTOY-003" }
    if (response.statusCode == 200 && response.data is Map) {
      final ref = response.data['reference'] as String?;
      if (ref != null && ref.isNotEmpty) return ref;
    }
    throw Exception('Référence non disponible');
  }
}

class PieceCritical {
  final String name;
  final String category;
  final String date;
  final List<String> compatibility;
  final int quantity;
  final int? sellingPrice;
  final String reference;
  final bool critical;
  final String? logo;

  // Constructeur corrigé avec des paramètres nommés
  PieceCritical({
    required this.name,
    required this.category,
    required this.date,
    required this.compatibility,
    required this.quantity,
    this.sellingPrice,
    required this.reference,
    required this.critical,
    this.logo,
  });

  factory PieceCritical.fromJson(Map<String, dynamic> json) {
    return PieceCritical(
      name: json['name'] as String,
      category: json['category'] as String,
      date: json['date'] as String,
      compatibility: (json['compatibility'] as List).cast<String>(),
      quantity: json['quantity'] as int,
      sellingPrice: json['sellingPrice'] as int?,
      reference: json['reference'] as String,
      critical: json['critical'] as bool,
      logo: json['logo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'date': date,
      'compatibility': compatibility,
      'quantity': quantity,
      'sellingPrice': sellingPrice,
      'reference': reference,
      'critical': critical,
      'logo': logo,
    };
  }
}
