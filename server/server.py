import json
import os

from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app) 

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
USERS_PATH = os.path.join(BASE_DIR, "data", "users.json")
VENTES_PATH = os.path.join(BASE_DIR, "data", "ventes.json")


def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save_json(path, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


@app.route("/api/register", methods=["POST"])
def register():
    body = request.get_json(silent=True) or {}
    email = body.get("email")
    password = body.get("password")
    nom = body.get("nom")
    prenom = body.get("prenom")

    if not email or not password or not nom or not prenom:
        return jsonify({"error": "email, password, nom et prenom sont requis"}), 400

    users = load_json(USERS_PATH)

    if any(u["email"] == email for u in users):
        return jsonify({"error": "Un compte existe déjà avec cet email"}), 409

    new_id = max((u["id"] for u in users), default=0) + 1
    new_user = {"id": new_id, "email": email, "password": password, "nom": nom, "prenom": prenom}
    users.append(new_user)
    save_json(USERS_PATH, users)

    user_safe = {k: v for k, v in new_user.items() if k != "password"}
    return jsonify(user_safe), 201


@app.route("/api/login", methods=["POST"])
def login():
    body = request.get_json(silent=True) or {}
    email = body.get("email")
    password = body.get("password")

    if not email or not password:
        return jsonify({"error": "email et password sont requis"}), 400

    users = load_json(USERS_PATH)
    user = next(
        (u for u in users if u["email"] == email and u["password"] == password),
        None,
    )

    if user is None:
        return jsonify({"error": "Email ou mot de passe incorrect"}), 401

    # Ne jamais renvoyer le mot de passe dans la réponse
    user_safe = {k: v for k, v in user.items() if k != "password"}
    return jsonify(user_safe), 200


@app.route("/api/produits", methods=["GET"])
def get_produits():
    produits = load_json(VENTES_PATH)
    return jsonify(produits), 200


@app.route("/api/produits/<int:produit_id>", methods=["GET"])
def get_produit(produit_id):
    produits = load_json(VENTES_PATH)
    produit = next((p for p in produits if p["id"] == produit_id), None)

    if produit is None:
        return jsonify({"error": "Produit non trouvé"}), 404

    return jsonify(produit), 200


if __name__ == "__main__":
    # host="0.0.0.0" pour être accessible depuis un appareil/émulateur sur le même réseau
    app.run(host="0.0.0.0", port=5000, debug=True)
