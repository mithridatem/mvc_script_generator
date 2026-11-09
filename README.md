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

Le générateur est publié sur **[Packagist](https://packagist.org/packages/mithridatem/mvc-script-generator)**. Composer installe la commande `mvc` ; **le moteur reste entièrement en Bash**.

```bash
composer global require mithridatem/mvc-script-generator
mvc --help
```

**Si `mvc` n'est pas reconnu**, ajouter le répertoire global `vendor/bin` de Composer au `PATH` de votre shell :

```bash
composer global config bin-dir --absolute
```

Sous **Windows avec Git Bash**, ouvrir `~/.bashrc` avec `nano ~/.bashrc` et ajouter **une seule fois** :

```bash
# Binaires Composer globaux — Git Bash Windows
COMPOSER_GLOBAL_BIN="$(composer global config bin-dir --absolute 2>/dev/null | tail -n 1)"
if [ -n "$COMPOSER_GLOBAL_BIN" ]; then
  COMPOSER_GLOBAL_BIN="$(cygpath -u "$COMPOSER_GLOBAL_BIN")"
  export PATH="$COMPOSER_GLOBAL_BIN:$PATH"
fi
```

Puis lancer :

```bash
source ~/.bashrc
hash -r
type -a mvc
mvc --help
```

Cela fonctionne également lorsque Composer est installé sous `AppData/Roaming/Composer` ; inutile d'inscrire un nom d'utilisateur Windows en dur. Pour Linux, macOS, les shells qui ne chargent pas `~/.bashrc` et la migration depuis l'ancienne installation locale, voir **[le guide complet d'installation et de configuration du PATH](docs/installation-composer.md)**.

```bash
# Créer un projet depuis le dossier courant
mvc --profile basic --name demo_basic
mvc --profile advanced --name demo_web
mvc --profile api-jwt --name demo_api

# Mise à jour et désinstallation du générateur
composer global update mithridatem/mvc-script-generator
composer global remove mithridatem/mvc-script-generator
```

**Migration depuis `install-local.sh` :** vérifier `type -a mvc` ; l'ancien lanceur `~/.local/bin/mvc` peut prendre la priorité sur celui de Composer. Le retirer avec `rm ~/.local/bin/mvc` uniquement si vous avez décidé de ne plus utiliser l'installation locale. Ne pas supprimer le dossier `~/.local/bin` lui-même.

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

## Utilisation et options

La commande `mvc` peut être utilisée depuis n'importe quel dossier après l'installation globale. Pour les contributeurs ayant cloné le dépôt, l'ancien point d'entrée `bash script.sh` reste disponible.

```bash
mvc --help
mvc --profile advanced --name demo_web --db-name demo_web
mvc --profile api-jwt --name demo_api --db-name demo_api
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

## Rendu HTML du profil Advanced Web

Le profil `advanced` est synchronisé avec `mvc_starter/variant/web` : `render()` et `renderComponent()` retournent du HTML sous forme de `string` grâce à un buffer commun. Les composants sont affichés dans les templates avec `<?= $this->renderComponent(...) ?>` et le résultat du routeur est envoyé par `Application`.

La PHPDoc des méthodes utilitaires est incluse dans les projets générés. Le profil fournit les tests `tests/template_render_test.php` et `tests/auth_form_render_test.php` ; les exécuter après `composer install`.

Les profils `basic` et `api-jwt` restent inchangés.

## Guides embarqués

Chaque projet généré contient un guide pratique dans `docs/guide-utilisation.md` : prise en main, parcours d'une requête, architecture, extension et vérifications. Les guides sont adaptés à chaque profil (`basic`, `advanced`, `api-jwt`) et sont copiés automatiquement avec le squelette. Les README restent des instructions de démarrage rapide.

## Bootstrap léger synchronisé

Les profils `advanced` et `api-jwt` reprennent désormais l'architecture validée dans les deux branches de `project_exemple` : un `public/index.php` minimal qui démarre `App\\Kernel\\Application`, une `RouterFactory` et un bootstrap/gestionnaire d'erreurs spécifiques au type d'application.

Le profil `basic` est volontairement **inchangé**. Les guides `docs/guide-utilisation.md` et les tests de bootstrap sont inclus dans les projets générés.

## Environnements et préparation à la production

Les deux profils avancés sont alignés sur leurs branches de référence `project_exemple` : `RouteGroup`, protection CSRF générique pour le Web, héritage JWT/grants pour l'API et `EnvironmentLoader`.

Chaque projet reçoit un fichier `.env` local, créé depuis `.env.example`, et ignoré par Git. `APP_ENV=dev` charge `.env` ; `APP_ENV=test` charge `.env.test` ; en **production**, définir `APP_ENV=prod` au niveau de l'hébergement et injecter les variables/secrets, sans fichier dotenv. Les guides embarqués `docs/environments.md` documentent la procédure. L'API génère un `JWT_SECRET` local et permet de configurer sa durée de vie avec `JWT_TTL_SECONDS`.
