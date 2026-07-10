/// Représente l'utilisateur connecté (sans mot de passe, jamais renvoyé par le serveur).
class User {
  final int id;
  final String email;
  final String nom;
  final String prenom;

  User({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'prenom': prenom,
    };
  }
}
