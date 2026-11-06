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

## Installation globale avec Composer (recommandée)

Le moteur de génération **reste en Bash**. Composer installe seulement le package
et expose la commande `mvc` dans son répertoire global d'exécutables.

> Publication Packagist : le package devra d'abord être enregistré sur
> [packagist.org](https://packagist.org/) et une version Git publiée.
> Avant cette publication, utiliser la méthode locale ci-dessous.

```bash
composer global require mithridatem/mvc-script-generator
```

Ajouter le répertoire global `bin` de Composer au `PATH` si nécessaire :

```bash
composer global config bin-dir --absolute
# Ajouter le répertoire affiché au PATH de votre terminal
```

Sous Git Bash (Windows), conserver PHP, Composer et Git Bash dans le `PATH`.
Pour rendre un ajout au `PATH` persistant, modifier `~/.bashrc`, et s'assurer
que `~/.bash_profile` le charge lorsque Git Bash démarre en login shell.
Le chemin global peut différer entre Windows, Linux et macOS : ne pas supposer
que `~/.config/composer/vendor/bin` est toujours le bon chemin.

```bash
mvc --help
cd ~/projets
mvc --profile basic --name demo
mvc --profile advanced --name bibliotheque
mvc --profile api-jwt --name api_books
```

Pour mettre à jour ou désinstaller le package :

```bash
composer global update mithridatem/mvc-script-generator
composer global remove mithridatem/mvc-script-generator
```

**Attention :** si `install-local.sh` a déjà installé `~/.local/bin/mvc`,
il peut prendre la priorité sur le lanceur Composer. Contrôler avec
`command -v mvc` ou `type -a mvc`; supprimer l'ancien lanceur avec
`rm ~/.local/bin/mvc` uniquement si vous souhaitez passer à Composer.
Les projets créés précédemment ne sont pas modifiés.

## Installation locale : commande `mvc` (sans Packagist)

Cloner le générateur **une seule fois** dans un dossier permanent :

```bash
git clone https://github.com/mithridatem/mvc_script_generator.git ~/tools/mvc_script_generator
cd ~/tools/mvc_script_generator
bash install-local.sh
```

Le script installe un petit lanceur dans `~/.local/bin/mvc`, pointant vers ce dépôt. **Conserver le dépôt à cet emplacement** : le lanceur utilise ses templates et le script de génération. Pour recevoir les évolutions, effectuer `git pull` dans ce dépôt (réinstaller seulement si tu le déplaces).

Si `mvc` n'est pas reconnu, ajouter ce dossier au `PATH` de Git Bash, Bash ou Zsh :

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Pour rendre le `PATH` permanent sous Linux/Bash, ajouter cette ligne dans `~/.bashrc` ; sous Zsh, l'ajouter à `~/.zshrc`. Sous Windows, utiliser **Git Bash** pour les commandes proposées.

### Git Bash sous Windows : conserver `mvc` après redémarrage

L'instruction `export PATH=...` ne s'applique qu'au terminal en cours. Pour retrouver la commande `mvc` dans chaque nouveau terminal Git Bash :

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

which mvc
mvc --help
```

Si `mvc` fonctionne après `source ~/.bashrc`, mais reste introuvable à l'ouverture d'un nouveau terminal, vérifier les fichiers de démarrage :

```bash
ls -la ~/.bashrc ~/.bash_profile
```

Git Bash peut être lancé comme un *login shell* et charger `~/.bash_profile`. Si ce fichier existe mais ne charge pas déjà `~/.bashrc`, ajouter **une seule fois** :

```bash
echo '[ -f ~/.bashrc ] && source ~/.bashrc' >> ~/.bash_profile
```

Fermer et rouvrir Git Bash, puis tester `mvc --help`. Avant d'ajouter des lignes, vérifier qu'elles ne sont pas déjà présentes pour éviter les doublons.

Pour distinguer un problème de `PATH` d'une installation incomplète :

```bash
ls -l ~/.local/bin/mvc
bash ~/.local/bin/mvc --help
```

Si ce dernier appel fonctionne mais pas `mvc --help`, le lanceur est installé ; il reste à rendre `~/.local/bin` accessible dans le `PATH` du nouveau terminal.

Depuis **n'importe quel dossier**, créer un projet dans le répertoire courant :

```bash
cd ~/projets
mvc --profile advanced --name bibliotheque
mvc --profile api-jwt --name api_books
mvc --profile basic --name projet_mvc
```

Ou choisir un dossier parent explicite avec `--target` (ce dossier doit exister) :

```bash
mvc --profile advanced --name bibliotheque --target ~/Documents/projets
```

Sans `--name`, le script demande le nom ; sans `--profile`, il propose le profil en mode interactif. Les anciennes commandes `bash script.sh ...` et toutes les options existantes fonctionnent toujours. L'installation **ne modifie pas** automatiquement les fichiers de configuration du shell.

Pour supprimer la commande locale : `rm ~/.local/bin/mvc`. Pour une destination personnalisée : `bash install-local.sh --bin-dir /chemin/vers/bin` (ajouter ensuite ce dossier au `PATH`). Le programme n'écrase pas une commande existante qu'il n'a pas installée.

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
bash tests/smoke-local-cli.sh
bash tests/smoke-composer-global.sh
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
