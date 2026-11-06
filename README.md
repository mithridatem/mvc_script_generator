# Générateur MVC PHP — Basic / Advanced Web / API JWT

Générateur pédagogique avec [mithridatem/router](https://github.com/evaluationWeb/router-librairie), la librairie de validation et [mithridatem/autowiring](https://github.com/mithridatem/autowiring-library).

| Profil | Objectif | Authentification |
|---|---|---|
| `basic` | MVC minimal, routing | Aucune |
| `advanced` | MVC Web avancé, DTO, services, repositories, middleware CSRF et RouteGroup | Session PHP + grants |
| `api-jwt` | API REST JSON, JWT Firebase, middleware d'authentification et RouteGroup | Bearer JWT + grants |

Le profil `advanced` reprend [project_exemple/main](https://github.com/evaluationWeb/project_exemple/tree/main). Le profil `api-jwt` reprend [project_exemple/variant/api-jwt](https://github.com/evaluationWeb/project_exemple/tree/variant/api-jwt). Les adaptations propres au générateur sont conservées.

## Prérequis

PHP 8.2+, Composer 2 et Bash (Linux/macOS/Git Bash). MySQL ou MariaDB pour les profils `advanced` et `api-jwt`.

## Utilisation

```bash
git clone https://github.com/mithridatem/mvc_script_generator.git
cd mvc_script_generator

bash script.sh --profile basic --name demo_basic
bash script.sh --profile advanced --name demo_web --db-name demo_web
bash script.sh --profile api-jwt --name demo_api --db-name demo_api

# Options
bash script.sh --help
```

Options communes : `--name`, `--profile`, `--target`, `--no-install`, `--db-host`, `--db-port`, `--db-name`, `--db-user`, `--configure-db`, `--help`.

Le script refuse l'écrasement d'un projet existant. Pour les deux profils avec BDD, il personnalise `db.sql` et `DATABASE_*`. Avec `--configure-db`, le mot de passe est demandé en mode interactif sans être affiché. Le projet `api-jwt` reçoit automatiquement un secret JWT distinct et aléatoire (`random_bytes(32)`) dans `.env`, ignoré de Git et de permissions `600`.

## Démarrage

```bash
cd demo_api # ou demo_web / demo_basic
composer install
php -S 127.0.0.1:8000 -t public
```

Pour les profils avec SQL : importer `db.sql`, puis vérifier le fichier `.env` généré. Documentation détaillée dans chaque dossier `templates/<profil>/README.md`.

## Vérifications du générateur

```bash
bash tests/smoke-basic.sh
bash tests/smoke-advanced.sh
bash tests/smoke-api-jwt.sh
```

Les smoke tests valident la génération, la syntaxe PHP, les structures de profils et la configuration sans base SQL. Le workflow GitHub Actions installe aussi les dépendances et exécute les tests des projets générés. Pour un déploiement public, revoir sécurité, secrets, HTTPS, rate limiting et gestion d'erreurs.

## Guides embarqués

Chaque projet généré contient un guide pratique dans `docs/guide-utilisation.md` : prise en main, parcours d'une requête, architecture, extension et vérifications. Les guides sont adaptés à chaque profil (`basic`, `advanced`, `api-jwt`) et sont copiés automatiquement avec le squelette. Les README restent des instructions de démarrage rapide.

## Bootstrap léger synchronisé

Les profils `advanced` et `api-jwt` reprennent désormais l'architecture validée dans les deux branches de `project_exemple` : un `public/index.php` minimal qui démarre `App\\Kernel\\Application`, une `RouterFactory` et un bootstrap/gestionnaire d'erreurs spécifiques au type d'application.

Le profil `basic` est volontairement **inchangé**. Les guides `docs/guide-utilisation.md` et les tests de bootstrap sont inclus dans les projets générés.

## Environnements et préparation à la production

Les deux profils avancés sont alignés sur leurs branches de référence `project_exemple` : `RouteGroup`, protection CSRF générique pour le Web, héritage JWT/grants pour l'API et `EnvironmentLoader`.

Chaque projet reçoit un fichier `.env` local, créé depuis `.env.example`, et ignoré par Git. `APP_ENV=dev` charge `.env` ; `APP_ENV=test` charge `.env.test` ; en **production**, définir `APP_ENV=prod` au niveau de l'hébergement et injecter les variables/secrets, sans fichier dotenv. Les guides embarqués `docs/environments.md` documentent la procédure. L'API génère un `JWT_SECRET` local et permet de configurer sa durée de vie avec `JWT_TTL_SECONDS`.
