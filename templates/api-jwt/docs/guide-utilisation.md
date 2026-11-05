# Guide d'utilisation — Profil API JWT

> **Objectif :** créer une API REST PHP renvoyant du JSON, avec authentification Bearer JWT, contrôle des rôles, séparation Controller / Service / Repository et aucun état de session PHP.

Ce guide décrit **le squelette actuel**. Le refactoring `Application / ApiBootstrap / RouterFactory / ApiErrorHandler` validé dans `project_exemple:variant/api-jwt` n'a pas encore été intégré au template du générateur : ici, `public/index.php` assemble directement le routeur.

## 1. Installation

Prérequis : PHP 8.2+, Composer, MySQL ou MariaDB, extensions PDO adaptées.

```bash
composer install
# Vérifier les variables DATABASE_* dans .env
# Créer les tables en important db.sql
php -S 127.0.0.1:8000 -t public
```

Le générateur crée `.env` et un **secret JWT aléatoire distinct pour chaque projet**, dans la variable `JWT_SECRET`. Ne jamais exposer ce secret ni committer `.env`.

Il faut disposer d'un utilisateur en base avant d'appeler `/api/login`. Ce squelette ne comporte **pas de route d'inscription**. Pour un premier essai, importer ou créer un utilisateur de test en utilisant un mot de passe haché avec `password_hash()`, jamais un mot de passe en clair.

## 2. Parcours d'une requête API

```text
POST /api/login (JSON)
  -> AuthController -> LoginInput -> LoginService -> UserRepository
  -> JwtTokenManager -> JSON { access_token, token_type, expires_in }

GET /api/profile (Authorization: Bearer <token>)
  -> RequestAuthenticationMiddleware (réinitialisation du contexte)
  -> JwtMiddleware (validation JWT)
  -> ContextGrantChecker (ROLE_USER)
  -> ProfileController -> JSON { id, email, roles }
```

L'API ne démarre **aucune session PHP** et n'utilise pas de CSRF basé sur les cookies. Les rôles proviennent uniquement d'un token correctement vérifié, pas de `$_SESSION`.

## 3. Effectuer les appels HTTP

**Authentification :**

```bash
curl -i -X POST http://127.0.0.1:8000/api/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"utilisateur@example.test","password":"mot-de-passe"}'
```

Si les identifiants sont corrects, le serveur répond avec un `access_token`, un `token_type` Bearer et un `expires_in` de 900 secondes (15 minutes).

**Profil protégé :**

```bash
curl -i http://127.0.0.1:8000/api/profile \
  -H 'Authorization: Bearer COLLER_LE_TOKEN_ICI'
```

Le client doit transmettre l'en-tête `Authorization` à chaque appel protégé.

## 4. Architecture et responsabilités

| Composant | Rôle |
| --- | --- |
| `public/index.php` | Point d'entrée, initialisation du routeur et gestion des erreurs JSON |
| `config/service.php` | Configuration du conteneur, fabrique PDO et paramètres JWT |
| `src/Controller/Api/` | Endpoints et sérialisation des réponses |
| `src/DTO/LoginInput.php` | Normalisation des données du login |
| `src/Service/LoginService.php` | Cas d'utilisation de connexion |
| `src/Repository/UserRepository.php` | Accès aux utilisateurs en base |
| `src/Middleware/JwtMiddleware.php` | Lit et vérifie le Bearer token |
| `src/Middleware/RequestAuthenticationMiddleware.php` | Réinitialise l'identité avant/après dispatch |
| `src/Security/Jwt/JwtTokenManager.php` | Émission, signature et validation des claims |
| `src/Security/Authentication/` | Identité vérifiée pendant la requête et contrôle des grants |

Le contrôleur ne doit pas effectuer directement la vérification cryptographique du JWT. Le service métier ne doit pas produire de réponse JSON.

## 5. Ajouter une route protégée

Créer un contrôleur sous `src/Controller/Api/` en déclarant la route :

```php
use App\Middleware\JwtMiddleware;
use Mithridatem\Routing\Attribute\Route;

#[Route(
    path: '/api/private',
    method: 'GET',
    grants: ['ROLE_USER'],
    middleware: [JwtMiddleware::class]
)]
public function privateEndpoint(): void
{
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['message' => 'Accès autorisé'], JSON_THROW_ON_ERROR);
}
```

Cette méthode doit être placée dans une **classe de contrôleur réelle**, sous le namespace `App\Controller\Api`. La découverte automatique chargera l'attribut `Route`.

**Très important :** ajouter `grants` sans `JwtMiddleware` sur une nouvelle route protégée n'est pas une configuration d'authentification suffisante. Ajouter explicitement le middleware JWT à chaque endpoint nécessitant un Bearer token.

## 6. Comprendre les réponses HTTP

| Statut | Signification dans ce projet |
| --- | --- |
| 200 | Connexion ou lecture du profil réussie |
| 400 | JSON d'entrée invalide |
| 401 | Identifiants incorrects ou token absent / invalide |
| 403 | Token valide, rôle requis absent |
| 404 | Route inconnue |
| 405 | Verbe HTTP non autorisé |

Les contrôles de signature, de date d'expiration et des claims JWT sont effectués par `JwtTokenManager`.

## 7. Tests

```bash
php tests/login_input_test.php
php tests/jwt_api_routes_test.php
php tests/jwt_authentication_test.php
```

Tests manuels conseillés : identifiants erronés, JSON invalide, profil sans en-tête, token falsifié, token expiré, token valide avec et sans `ROLE_USER`.

## 8. Sécurité et limites du POC

- Utiliser **HTTPS** en production ; éviter de transmettre un JWT via URL ou logs.
- Le secret doit être long, imprévisible et protégé ; ne pas réutiliser le même secret entre environnements.
- Les rôles du token sont figés à l'émission : un changement en base ne modifie pas les tokens déjà délivrés.
- Aucun refresh token, aucune révocation, aucune rotation automatique des clés.
- Ajouter en situation réelle : limitation des tentatives, CORS adapté, journalisation maîtrisée et politique de gestion des tokens.
- Le squelette ne gère pas automatiquement tous les scénarios d'erreur métier : compléter les tests d'intégration et les contrôles de sécurité.

Voir aussi `docs/jwt-api.md` pour les choix d'authentification et les limites de ce POC.
