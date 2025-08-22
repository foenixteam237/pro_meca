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
        // Vérifie si la réponse contient une liste dans 'data'
        final List<dynamic> data = response.data ?? [];

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
      print(response);
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
}
