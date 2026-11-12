# MVC Basic

## Guide pas à pas

Après génération, consulter **[docs/guide-utilisation.md](docs/guide-utilisation.md)** pour comprendre le parcours des requêtes, le rôle des composants et ajouter une fonctionnalité pas à pas.

Ce projet utilise `mithridatem/router` et `vlucas/phpdotenv` : pas de conteneur ni de librairie de validation.

```sh
composer install
php -S 127.0.0.1:8000 -t public
```

Ouvrez http://127.0.0.1:8000/.

### Exemple de formulaire

La page **http://127.0.0.1:8000/bonjour** propose un formulaire accessible en GET et traité en POST par `FormController::bonjour(RequestInterface $request)`.

Le contrôleur utilise `$request->post('name', '')` plutôt que `$_POST`, puis appelle `ExampleService` pour construire le message. Le template `templates/form.php` échappe les données affichées. Voir le guide pour le parcours détaillé.

Pour lancer le test après `composer install` :

```bash
php tests/form_request_test.php
```


- `public/index.php` : routeur et point d'entrée.
- `src/Controller` : entrée/sortie HTTP.
- `src/Service` : logique métier.
- `src/Repository` : persistance PDO.
- `src/Entity` : objets métier.
- `templates` : vues.

Le squelette n'a pas besoin de base de données pour la page d'accueil. Si `.env` existe, le point d'entrée le charge sans ouvrir de connexion. La connexion PDO ne s'effectue qu'à la demande.

## Bases de données : MySQL, PostgreSQL et SQLite

Le profil propose `ConnectionInterface`, `ConnectionFactory` et trois adaptateurs PDO (`Mysql`, `Postgresql`, `Sqlite`). Choisir `DATABASE_DRIVER=mysql|pgsql|sqlite` dans `.env` ou `mvc --db-driver ...` à la génération (MySQL/MariaDB par défaut).

- MySQL/MariaDB : `db.sql` pour les profils disposant d'un schéma d'authentification.
- PostgreSQL : `database/postgresql.sql` (après création de la base) pour les profils avancés.
- SQLite : `database/sqlite.sql` et `DATABASE_PATH=var/database.sqlite` pour les profils avancés.

Le profil basic reste utilisable sans base de données ; les schémas ne sont pas imposés. Les fichiers SQLite sont conservés hors de `public/`. Les repositories des profils avancés continuent à recevoir un objet `PDO`.

Consulter [docs/databases.md](docs/databases.md) pour la configuration et exécuter `php tests/database_connection_test.php` après `composer install`.
