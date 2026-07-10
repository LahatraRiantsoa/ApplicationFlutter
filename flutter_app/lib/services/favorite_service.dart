import 'package:shared_preferences/shared_preferences.dart';

/// Gère la persistance locale des produits favoris avec SharedPreferences.
class FavoriteService {
  static const _key = 'favorite_product_ids';

  /// Récupère l'ensemble des identifiants de produits favoris.
  static Future<Set<int>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    return ids.map(int.parse).toSet();
  }

  /// Ajoute ou retire un produit des favoris et renvoie le nouvel ensemble.
  static Future<Set<int>> toggleFavorite(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteIds();

    if (favorites.contains(productId)) {
      favorites.remove(productId);
    } else {
      favorites.add(productId);
    }

    await prefs.setStringList(_key, favorites.map((id) => id.toString()).toList());
    return favorites;
  }
}
