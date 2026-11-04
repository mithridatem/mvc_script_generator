# MVC Advanced — Routing + Validation + Autowiring

Squelette pédagogique dérivé de `evaluationWeb/project_exemple`.
Il montre une inscription et une connexion avec séparation des responsabilités.

## Installation

Dépendances déclarées dans `composer.json` : `mithridatem/router:^1.4`,
`mithridatem/validation:^1.2` et `mithridatem/autowiring:^1.4`.
La version 1.4 d'autowiring permet également l'enregistrement optionnel de factories objets via `FactoryInterface` ; la factory PDO existante reste inchangée.


```sh
composer install
# Modifier .env (notamment DATABASE_PASSWORD) si nécessaire
# Importer db.sql dans MySQL/MariaDB pour créer la base et la table user
php -S 127.0.0.1:8000 -t public
```

Accueil : http://127.0.0.1:8000/
Inscription : http://127.0.0.1:8000/register
Connexion : http://127.0.0.1:8000/login

## Architecture

- `public/index.php` : routeur + conteneur et démarrage session.
- `src/Controller` : gestion HTTP et rendu.
- `src/DTO` : données d'entrée et contraintes de validation.
- `src/Service` : orchestration des cas d'utilisation.
- `src/Repository` : persistance SQL via PDO.
- `src/Security` : hachage, session d'authentification et protection CSRF par formulaire.
- `config/service.php` : déclaration de la fabrique PDO et de la configuration du service d'upload.
- `src/Service/UploadFileService.php` : squelette pédagogique d'upload (méthode non implémentée).
- `src/Utils/Tools.php` : utilitaires provenant du projet de référence.

Les actions POST `LoginController::login()` et `RegisterController::register()`
reçoivent `ParameterCollectionRequestInterface` (router `^1.4`) et construisent
leurs DTO avec `fromArray($request->allPost())`. Les données HTTP restent dans
la couche contrôleur ; les services conservent leurs signatures DTO.
Les champs non attendus sont ignorés par les méthodes `fromArray()`.
La vérification CSRF reste effectuée avant la création des DTO.

## Vérifier

```sh
php tests/register_user_input_test.php
php tests/login_input_test.php
php tests/csrf_token_manager_test.php
php tests/form_submission_test.php
php tests/user_session_manager_test.php
php tests/auth_form_render_test.php
php tests/request_dto_mapping_test.php
```

Puis tester le parcours réel avec MySQL : inscription, doublon d'email, identifiants erronés, connexion et session. Ces tests autonomes ne remplacent pas des tests d'intégration.

La protection CSRF est assurée par `Security/CsrfTokenManager` : un token par formulaire (`login` / `register`), vérifié avant les services métier. Le token est conservé lorsque le formulaire est réaffiché après une erreur. Chaque contrôleur utilise une méthode privée de rendu dédiée (`renderLoginForm` / `renderRegisterForm`) et un unique appel de rendu en fin de traitement ; les conditions CSRF sont explicites sans `else`. `AbstractController::isFormSubmitted()` contrôle la méthode HTTP POST, sans dépendre du bouton de soumission.

**Sécurité** : le squelette est pédagogique. Pour un déploiement public, ajouter limitation des tentatives, tests d'intégration et une gestion cohérente des exceptions SQL. Ne jamais committer `.env`.
