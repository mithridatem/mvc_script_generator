# MVC Advanced — Web : sessions PHP + protection CSRF

## Guide pas à pas

Après génération, consulter **[docs/guide-utilisation.md](docs/guide-utilisation.md)** pour comprendre le parcours des requêtes, le rôle des composants et ajouter une fonctionnalité pas à pas.

Profil pédagogique basé sur [project_exemple / variant/web-session-csrf](https://github.com/evaluationWeb/project_exemple/tree/variant/web-session-csrf), consacré au Web avec sessions et CSRF.

Il utilise `mithridatem/router`, `mithridatem/validation` et `mithridatem/autowiring`. Authentification HTML en session PHP, `grants` de routes et vérification CSRF dans le **middleware** (plus dans les contrôleurs).

## Environnements

`APP_ENV=dev` utilise `.env`, `APP_ENV=test` charge `.env.test` et **`APP_ENV=prod` n'utilise aucun fichier dotenv** : injecter les variables/secrets depuis le serveur ou le conteneur. Voir [docs/environments.md](docs/environments.md). Les routes Login/Register utilisent désormais `RouteGroup` et le CSRF générique sans registre de formulaires.

## Installer

```bash
composer install
# Configurer le fichier .env généré (notamment DATABASE_PASSWORD)
# Importer db.sql dans MySQL/MariaDB
php -S 127.0.0.1:8000 -t public
```

Parcours : `GET /login`, `POST /login`, `GET /register`, `POST /register`. Les requêtes POST sont protégées par `CsrfMiddleware`. Une soumission sans token valide provoque une réponse HTTP 403 accompagnée d'une page HTML et d'un lien vers l'accueil. Le contrôleur ne traite que les DTO et les cas d'utilisation. Les rôles Web continuent de provenir de la session PHP : `AuthenticationAwareGrantChecker` délègue les rôles à `ArrayGrantChecker` et ajoute `IS_GUEST` / `IS_AUTHENTICATED`. Les routes `/login` et `/register` sont réservées aux invités en GET et POST ; un utilisateur connecté est redirigé vers la dernière page GET autorisée ou un repli local (`/` par défaut). Voir [docs/guest-navigation.md](docs/guest-navigation.md).

## Architecture

- `public/index.php` : point d'entrée minimal, lance `Application`.
- `src/Kernel/Application.php` : orchestration du démarrage.
- `src/Kernel/WebBootstrap.php` : chargement de l'environnement, en-têtes et session PHP.
- `src/Kernel/RouterFactory.php` : routeur, résolveurs, grants et découverte des routes.
- `src/Kernel/WebErrorHandler.php` : traduit les exceptions en statuts HTTP et prévoit un HTML de secours.
- `src/Controller/ErrorController.php` : définit les messages et liens de navigation des erreurs.
- `template/template_error.php` : template HTML commun aux erreurs.
- `src/Middleware/CsrfMiddleware.php` : vérification des tokens avant exécution du contrôleur.
- `src/Middleware/ContainerMiddlewareResolver.php` : adaptation au conteneur autowiring.
- `src/Security/GuestNavigation.php` : mémorisation en session et redirection des utilisateurs déjà connectés.
- `src/Security/CsrfTokenManager.php` : génération et validation par session.
- `src/Controller` : traitements HTTP, templates HTML.
- `src/DTO` : entrées validées ; `src/Service` : métier ; `src/Repository` : accès PDO.
- `config/service.php` : fabrique PDO et configuration upload.

La correction d'hydratation de l'entité `User`, le DSN MySQL et les placeholders du générateur sont conservés.

## Rendu HTML

Dans ce profil, `AbstractController::render()` renvoie le HTML d'un template complet et `renderComponent()` renvoie celui d'un composant. Les deux utilisent un buffer commun et **n'écrivent pas directement dans la réponse**. Les vues doivent afficher explicitement les composants avec `<?= $this->renderComponent(...) ?>`. Le point d'entrée Web émet la chaîne retournée par le routeur.

Les méthodes utilitaires disposent de PHPDoc détaillées (paramètres, retours et exceptions). Exemples et précautions : [guide d'utilisation](docs/guide-utilisation.md).

## Pages d'erreur HTTP

Les statuts 401, 403, 404, 405 et 500 utilisent un template HTML commun via `ErrorController::error()`, appelé directement par `WebErrorHandler` (sans nouvelle route). Les erreurs 403/404/405/500 proposent un retour à l'accueil et 401 propose une connexion. Les détails techniques des exceptions ne sont pas exposés ; un rendu de secours reste disponible si la vue échoue. L'en-tête HTTP `Allow` des erreurs 405 et la navigation `IS_GUEST` sont conservés.

## Tests

```bash
php tests/environment_loader_test.php
php tests/web_kernel_test.php
php tests/guest_navigation_test.php
php tests/login_input_test.php
php tests/register_user_input_test.php
php tests/csrf_token_manager_test.php
php tests/csrf_middleware_test.php
php tests/csrf_route_configuration_test.php
php tests/form_submission_test.php
php tests/user_session_manager_test.php
php tests/auth_form_render_test.php
php tests/template_render_test.php
php tests/request_dto_mapping_test.php
```

Puis tester le parcours complet sur une base de données réelle. Aucun endpoint JWT n'est généré dans ce profil. Ne committer ni `.env` ni les identifiants.
