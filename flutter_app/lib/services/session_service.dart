import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

/// Gère la persistance locale de la session utilisateur avec SharedPreferences.
class SessionService {
  static const _keyId = 'user_id';
  static const _keyEmail = 'user_email';
  static const _keyNom = 'user_nom';
  static const _keyPrenom = 'user_prenom';

  /// Sauvegarde les informations de l'utilisateur connecté après une connexion réussie.
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyId, user.id);
    await prefs.setString(_keyEmail, user.email);
    await prefs.setString(_keyNom, user.nom);
    await prefs.setString(_keyPrenom, user.prenom);
  }

  /// Relit la session stockée localement, si elle existe (utilisé au démarrage pour l'auto-login).
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_keyId);
    final email = prefs.getString(_keyEmail);
    final nom = prefs.getString(_keyNom);
    final prenom = prefs.getString(_keyPrenom);

    if (id == null || email == null || nom == null || prenom == null) {
      return null;
    }

    return User(id: id, email: email, nom: nom, prenom: prenom);
  }

  /// Supprime la session locale (déconnexion).
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyId);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyNom);
    await prefs.remove(_keyPrenom);
  }
}
