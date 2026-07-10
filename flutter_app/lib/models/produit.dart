/// Représente un produit du catalogue de ventes privées.
class Produit {
  final int id;
  final String image;
  final String titre;
  final String description;
  final String categorie;
  final double prix;

  Produit({
    required this.id,
    required this.image,
    required this.titre,
    required this.description,
    required this.categorie,
    required this.prix,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'] as int,
      image: json['image'] as String,
      titre: json['titre'] as String,
      description: json['description'] as String,
      categorie: json['categorie'] as String,
      prix: (json['prix'] as num).toDouble(),
    );
  }
}
