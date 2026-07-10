"""Serveur backend pour l'application de ventes privées.

Expose une API REST (Flask) pour l'authentification et le catalogue de produits.
Les données sont stockées dans des fichiers JSON (data/users.json, data/ventes.json).
"""

import json
import os

from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # autorise les appels depuis l'application Flutter

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
USERS_PATH = os.path.join(BASE_DIR, "data", "users.json")
VENTES_PATH = os.path.join(BASE_DIR, "data", "ventes.json")


def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


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
