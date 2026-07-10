import 'package:flutter/material.dart';

import '../models/produit.dart';
import '../services/favorite_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Produit produit;

  const ProductDetailScreen({super.key, required this.produit});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final favorites = await FavoriteService.getFavoriteIds();
    if (mounted) setState(() => _isFavorite = favorites.contains(widget.produit.id));
  }

  Future<void> _toggleFavorite() async {
    final favorites = await FavoriteService.toggleFavorite(widget.produit.id);
    if (mounted) setState(() => _isFavorite = favorites.contains(widget.produit.id));
  }

  @override
  Widget build(BuildContext context) {
    final produit = widget.produit;
    return Scaffold(
      appBar: AppBar(
        title: Text(produit.titre),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            color: _isFavorite ? Colors.red : null,
            tooltip: _isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              produit.image,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(
                height: 280,
                child: Icon(Icons.broken_image, size: 64),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(label: Text(produit.categorie)),
                  const SizedBox(height: 12),
                  Text(
                    produit.titre,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${produit.prix.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(produit.description, style: const TextStyle(fontSize: 15, height: 1.4)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Retour à la liste'),
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
