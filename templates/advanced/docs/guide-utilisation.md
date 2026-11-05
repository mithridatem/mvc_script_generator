# Guide d'utilisation — Profil Advanced Web

> **Objectif :** développer une application Web PHP avec séparation des responsabilités, DTO, validation, services, repository PDO, injection de dépendances, session et protection CSRF.

Ce guide décrit **les fichiers effectivement générés**. Le bootstrap allégé `Application / RouterFactory`, récemment mis en place dans `project_exemple/main`, n'est pas encore synchronisé ici : dans ce squelette, la configuration Web se trouve encore dans `public/index.php`.

## 1. Préparer l'environnement

Pré requis : PHP 8.2+, Composer, MySQL ou MariaDB, extension `pdo_mysql`.

```bash
composer install
# Adapter DATABASE_HOST, DATABASE_PORT, DATABASE_NAME,
# DATABASE_USERNAME, DATABASE_PASSWORD dans .env
# Importer le fichier db.sql avec votre client MySQL
php -S 127.0.0.1:8000 -t public
```

Le générateur a créé `.env` et remplacé le nom de base dans `db.sql`. Ne jamais versionner `.env`.

Visiter `/`, `/register` puis `/login`. L'inscription crée un compte ; la connexion met l'utilisateur en session.

## 2. Parcours d'une requête POST

```text
POST /login (formulaire HTML + csrf_token)
      |
      v
public/index.php
  session + dotenv + Container + Router
      |
      v
#[Route(..., middleware: [CsrfMiddleware::class])]
      |
      v
CsrfMiddleware -> validation du jeton de formulaire
      |
      v
LoginController -> LoginInput::fromArray($request->allPost())
      |
      v
LoginService -> Validator + UserRepository + PasswordHasher
      |
      v
UserSessionManager -> session PHP -> redirection
```

Un jeton CSRF absent ou invalide est rejeté **avant** l'exécution du contrôleur (HTTP 403).

## 3. Responsabilités et fichiers

| Composant | Rôle |
| --- | --- |
| `public/index.php` | Démarre la session, charge les services et crée le routeur |
| `config/service.php` | Déclare la factory PDO et les paramètres du service d'upload |
| `src/Controller/` | Actions HTTP, rendu des templates et redirections |
| `src/DTO/` | Objets représentant les données d'entrée |
| `src/Service/` | Cas d'utilisation métier |
| `src/Repository/` | Requêtes SQL, hydratation des entités |
| `src/Entity/` | Objets métier |
| `src/Middleware/` | Vérifications transversales (ici CSRF) |
| `src/Security/` | Session, gestion CSRF et mots de passe |
| `template/` | Vues PHP/HTML |
| `tests/` | Vérifications autonomes du comportement |

**Règle pratique :** le contrôleur ne réalise pas de SQL, le repository ne génère pas de HTML et le service ne lit pas directement `$_POST`.

## 4. Déclarer une route

Une action déclarée avec un attribut est découverte automatiquement :

```php
use Mithridatem\Routing\Attribute\Route;

#[Route(path: '/catalogue', method: 'GET', grants: ['ROLE_USER'])]
public function catalogue(): mixed
{
    // Demander les données au service, puis rendre la vue.
}
```

Les `grants` permettent de demander un rôle. Dans ce profil, ils sont construits depuis `$_SESSION['user']['grant']` par `ArrayGrantChecker`.

Une route `POST` avec formulaire sensible doit être protégée. **Attention :** `CsrfMiddleware` fourni dans ce squelette ne connaît que les formulaires `/login` et `/register`. Il ne suffit donc pas de le copier tel quel sur `/catalogue` : il faut adapter explicitement la correspondance route → identifiant de formulaire et générer le jeton correspondant.

## 5. Exemple de parcours : inscription

1. `GET /register` affiche un formulaire contenant un jeton généré par `CsrfTokenManager`.
2. `POST /register` déclenche `CsrfMiddleware` qui vérifie ce jeton.
3. `RegisterController` construit `RegisterUserInput` avec `allPost()`.
4. `UserService` applique les validations et recherche les doublons via `UserRepository`.
5. Le repository utilise PDO pour enregistrer l'entité `User`.
6. Le contrôleur rend le résultat en HTML.

Ces étapes montrent clairement la différence entre **contrôle technique**, **orchestration HTTP**, **règles métier** et **persistance**.

## 6. Autowiring : où configurer une dépendance ?

Les classes concrètes sont résolues automatiquement lorsque le conteneur peut construire leurs paramètres.

`config/service.php` déclare par exemple la factory PDO :

```php
$container->factory(
    PDO::class,
    static fn (): PDO => Mysql::connectBdd()
);
```

Pour un paramètre scalaire, utiliser `configure()`, comme pour `UploadFileService`. Les services métiers ne doivent pas manipuler eux-mêmes le conteneur.

## 7. Tests et vérifications

```bash
php tests/login_input_test.php
php tests/register_user_input_test.php
php tests/csrf_token_manager_test.php
php tests/csrf_middleware_test.php
php tests/csrf_route_configuration_test.php
php tests/request_dto_mapping_test.php
php tests/form_submission_test.php
php tests/auth_form_render_test.php
php tests/user_session_manager_test.php
```

Tester également en navigateur avec une vraie base de données : formulaire valide, mauvais mot de passe, email déjà utilisé, POST sans jeton CSRF et session connectée.

## 8. Sécurité et limites

- En production : HTTPS, cookies sécurisés, limitation des tentatives de connexion, protection des secrets et gestion contrôlée des erreurs SQL.
- Toujours échapper les valeurs dynamiques dans les templates HTML.
- Ne pas modifier les rôles depuis des données envoyées par le navigateur.
- Ne pas désactiver le CSRF sous prétexte qu'un utilisateur est connecté.
- Le squelette est pédagogique et doit être complété par des tests d'intégration selon le projet.

**Pour les détails :** consulter `docs/csrf-middleware.md`, puis le code réel de `LoginController`, `CsrfMiddleware` et `UserService`.
