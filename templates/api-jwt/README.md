# MVC API JWT — Routing + Validation + Autowiring + Firebase JWT

Profil pédagogique dérivé de [project_exemple, branche `variant/api-jwt`](https://github.com/evaluationWeb/project_exemple/tree/variant/api-jwt). **API REST uniquement** : pas de session PHP, pas de vues HTML, pas de CSRF cookie. Les routes utilisent toujours `grants`.

## Installation

```sh
composer install
# Vérifier les paramètres DATABASE_* et JWT_* dans .env
# Importer db.sql dans MySQL/MariaDB
php -S 127.0.0.1:8000 -t public
```

Le générateur crée un `JWT_SECRET` aléatoire avec `random_bytes(32)` dans le fichier `.env`, ignoré par Git. Ne jamais committer `.env`. Le JWT d'accès a une durée de 15 min, sans refresh token ni révocation dans ce POC.

## Requêtes

```sh
curl -X POST http://127.0.0.1:8000/api/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"user@example.test","password":"mot_de_passe"}'

curl http://127.0.0.1:8000/api/profile \
  -H 'Authorization: Bearer VOTRE_TOKEN'
```

- `POST /api/login` : valide le JSON via `LoginInput` et `LoginService` et retourne un access token.
- `GET /api/profile` : authentification par `JwtMiddleware`, contrôle `ROLE_USER` via `ContextGrantChecker`.
- HTTP 401 pour token absent/invalide, 403 pour droits insuffisants.
- Aucune dépendance JWT ajoutée à `router-librairie`.

## Architecture

`Controller/Api` : endpoints JSON ; `Security/Jwt` : émission et validation ; `Security/Authentication` : identité pendant la requête ; `Middleware` : contrôle transversal ; `Repository` : PDO ; `Service` : métier.

## Vérification

```sh
php tests/login_input_test.php
php tests/jwt_api_routes_test.php
php tests/jwt_authentication_test.php
```

Voir `docs/jwt-api.md` pour les limites de sécurité. En production : HTTPS, protection contre la force brute, politique de révocation/rotation et suivi des autorisations.
