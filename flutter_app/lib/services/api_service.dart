import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../models/produit.dart';
import '../models/user.dart';

/// Exception dédiée aux erreurs applicatives renvoyées par l'API
/// (identifiants invalides, produit introuvable, etc.).
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  // 10.0.2.2 pointe vers le "localhost" de la machine hôte depuis un émulateur Android.
  // Sur un appareil physique ou un simulateur iOS/desktop, remplacez par l'IP locale
  // de votre machine (ex: http://192.168.1.42:5000) si "localhost" ne fonctionne pas.
  static String get _host {
    if (!kIsWeb && Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get baseUrl => 'http://$_host:5000/api';

  /// Authentifie l'utilisateur via POST /api/login.
  /// Lève une [ApiException] si les identifiants sont invalides ou en cas d'erreur réseau.
  static Future<User> login(String email, String password) async {
    final Uri uri = Uri.parse('$baseUrl/login');
    http.Response response;
    try {
      response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
    } catch (_) {
      throw ApiException('Impossible de contacter le serveur. Vérifiez votre connexion.');
    }

    final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return User.fromJson(body);
    }

    throw ApiException(body['error'] as String? ?? 'Échec de la connexion');
  }

  /// Récupère la liste complète des produits via GET /api/produits.
  static Future<List<Produit>> fetchProduits() async {
    final Uri uri = Uri.parse('$baseUrl/produits');
    http.Response response;
    try {
      response = await http.get(uri);
    } catch (_) {
      throw ApiException('Impossible de contacter le serveur. Vérifiez votre connexion.');
    }

    if (response.statusCode != 200) {
      throw ApiException('Échec du chargement des produits');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((json) => Produit.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Récupère le détail d'un produit via GET /api/produits/{id}.
  static Future<Produit> fetchProduit(int id) async {
    final Uri uri = Uri.parse('$baseUrl/produits/$id');
    http.Response response;
    try {
      response = await http.get(uri);
    } catch (_) {
      throw ApiException('Impossible de contacter le serveur. Vérifiez votre connexion.');
    }

    if (response.statusCode != 200) {
      throw ApiException('Produit introuvable');
    }

    return Produit.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
