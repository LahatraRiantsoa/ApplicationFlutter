import 'package:flutter/material.dart';

import '../models/produit.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../services/session_service.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';

const String _allCategories = 'Toutes';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Produit>? _produits;
  Object? _error;
  User? _user;
  Set<int> _favoriteIds = {};

  String _searchQuery = '';
  String _selectedCategory = _allCategories;
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadProduits();
    _loadUser();
    _loadFavorites();
  }

  Future<void> _loadProduits() async {
    try {
      final produits = await ApiService.fetchProduits();
      if (mounted) setState(() => _produits = produits);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _loadUser() async {
    final user = await SessionService.getUser();
    if (mounted) setState(() => _user = user);
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoriteService.getFavoriteIds();
    if (mounted) setState(() => _favoriteIds = favorites);
  }

  Future<void> _toggleFavorite(int productId) async {
    final favorites = await FavoriteService.toggleFavorite(productId);
    if (mounted) setState(() => _favoriteIds = favorites);
  }

  Future<void> _logout() async {
    // Suppression de la session locale puis retour à l'écran de connexion
    await SessionService.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  List<Produit> _filteredProduits(List<Produit> produits) {
    final query = _searchQuery.trim().toLowerCase();
    return produits.where((p) {
      final matchesQuery = query.isEmpty || p.titre.toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == _allCategories || p.categorie == _selectedCategory;
      final matchesFavorite = !_showFavoritesOnly || _favoriteIds.contains(p.id);
      return matchesQuery && matchesCategory && matchesFavorite;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user == null ? 'Ventes Privées' : 'Bonjour ${_user!.prenom}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: _logout,
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (_error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erreur: $_error', textAlign: TextAlign.center),
              ),
            );
          }

          final produits = _produits;
          if (produits == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = <String>[
            _allCategories,
            ...{for (final p in produits) p.categorie},
          ];
          final filtered = _filteredProduits(produits);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un produit...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: [
                    for (final categorie in categories)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(categorie),
                          selected: _selectedCategory == categorie,
                          onSelected: (_) => setState(() => _selectedCategory = categorie),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        avatar: Icon(
                          _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: _showFavoritesOnly ? Colors.red : null,
                        ),
                        label: const Text('Favoris'),
                        selected: _showFavoritesOnly,
                        onSelected: (value) => setState(() => _showFavoritesOnly = value),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Aucun produit ne correspond à votre recherche.'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final produit = filtered[index];
                          return _ProductCard(
                            produit: produit,
                            isFavorite: _favoriteIds.contains(produit.id),
                            onToggleFavorite: () => _toggleFavorite(produit.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Produit produit;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _ProductCard({
    required this.produit,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProductDetailScreen(produit: produit)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    produit.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 48),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.black45,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                      onPressed: onToggleFavorite,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produit.titre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${produit.prix.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
