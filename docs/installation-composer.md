# Installer MVC Script Generator avec Composer

Le package [mithridatem/mvc-script-generator](https://packagist.org/packages/mithridatem/mvc-script-generator) est disponible sur Packagist. Il utilise **Composer pour la distribution**, mais le générateur lui-même reste un script **Bash**.

## Prérequis

- PHP 8.2 ou supérieur
- Composer 2
- Bash : Linux, macOS ou **Git Bash sous Windows**
- MySQL/MariaDB pour les projets générés avec les profils `advanced` et `api-jwt`

## 1. Installation globale

Dans le terminal Bash ou Git Bash :

```bash
composer global require mithridatem/mvc-script-generator
```

Composer installe l'exécutable `mvc` dans son dossier global `vendor/bin`.

## 2. Ajouter l'exécutable Composer au PATH de Bash

Identifier le chemin réel, car il dépend du système et de l'installation Composer :

```bash
composer global config bin-dir --absolute
```

### Windows : Git Bash

Par exemple, un résultat Windows peut ressembler à :

```text
C:\\Users\\<utilisateur>\\AppData\\Roaming\\Composer\\vendor\\bin
```

Le même dossier peut être exprimé sous Git Bash en `/c/Users/<utilisateur>/AppData/Roaming/Composer/vendor/bin`. Éviter de copier un chemin contenant le nom d'un autre utilisateur.

**Méthode conseillée, sans chemin en dur :** ajouter ceci **une seule fois** dans `~/.bashrc` :

```bash
# Executables Composer globaux (Git Bash)
COMPOSER_GLOBAL_BIN="$(composer global config bin-dir --absolute 2>/dev/null | tail -n 1)"
if [ -n "$COMPOSER_GLOBAL_BIN" ]; then
  COMPOSER_GLOBAL_BIN="$(cygpath -u "$COMPOSER_GLOBAL_BIN")"
  export PATH="$COMPOSER_GLOBAL_BIN:$PATH"
fi
```

Avec `nano ~/.bashrc`, coller le bloc, enregistrer puis recharger :

```bash
source ~/.bashrc
hash -r
type -a mvc
mvc --help
```

**Alternative** si `APPDATA` est défini dans Git Bash et que le dossier Composer est le dossier Windows par défaut :

```bash
export PATH="$(cygpath -u "$APPDATA")/Composer/vendor/bin:$PATH"
```

Cette commande seule est temporaire ; la mettre dans `~/.bashrc` pour la conserver.

Si un nouveau terminal ne charge pas `~/.bashrc`, contrôler `~/.bash_profile`. Si ce fichier existe mais ne source pas déjà `~/.bashrc`, y ajouter une seule fois :

```bash
[ -f ~/.bashrc ] && source ~/.bashrc
```

### Linux (Bash) ou macOS (Bash/Zsh)

Récupérer le résultat de `composer global config bin-dir --absolute`, puis ajouter **ce dossier exact** au `PATH` dans `~/.bashrc` (Bash) ou `~/.zshrc` (Zsh) :

```bash
export PATH="/chemin/retourne/par/composer:$PATH"
```

Recharger le fichier de configuration du shell, puis utiliser `command -v mvc` et `mvc --help` pour vérifier.

## 3. Migrer depuis l'ancien installateur Bash

L'ancienne installation via `bash install-local.sh` créait le lanceur `~/.local/bin/mvc` pointant vers un clone local du dépôt.

Vérifier d'abord les commandes disponibles :

```bash
type -a mvc
```

Si l'ancien `~/.local/bin/mvc` est présent et si vous souhaitez utiliser uniquement la version Composer, supprimer **le lanceur uniquement** :

```bash
rm ~/.local/bin/mvc
hash -r
type -a mvc
```

Ne pas supprimer tout `~/.local/bin`. Si vous souhaitez aussi supprimer le clone local, vérifier au préalable l'absence de modifications ou de fichiers personnels, puis supprimer le dossier de clone manuellement. Aucun projet déjà généré n'est affecté.

## 4. Utiliser la commande

Depuis n'importe quel dossier :

```bash
mvc --help
mvc --profile basic --name demo_basic
mvc --profile advanced --name demo_web
mvc --profile api-jwt --name demo_api
```

Sans `--profile`, le profil est proposé en mode interactif ; sans `--name`, le nom est demandé. `--target /chemin/vers/dossier` permet de définir le dossier parent, qui doit déjà exister.

## 5. Mettre à jour ou supprimer

```bash
composer global update mithridatem/mvc-script-generator
composer global remove mithridatem/mvc-script-generator
```

Les projets déjà générés ne sont pas modifiés par la mise à jour du générateur.

## 6. Dépannage

**`mvc: command not found`** : contrôler le répertoire Composer avec `composer global config bin-dir --absolute`, le contenu du `PATH` (`printf '%s\\n' "$PATH"`) et `type -a mvc`. Ouvrir un nouveau terminal après modification des fichiers du shell.

**L'ancienne version s'exécute** : `type -a mvc` affiche l'ordre des commandes ; retirer l'ancien lanceur uniquement si vous n'en avez plus besoin.

**`bash: ...: bad substitution` sous macOS** : mettre à jour vers une version actuelle du générateur ; les versions récentes n'utilisent plus l'expansion Bash 4 `\${NAME,,}`.

**Sous PowerShell ou CMD** : le générateur est conçu pour Bash ; utiliser Git Bash ou WSL sous Windows.

Pour contribuer au générateur lui-même, l'installation par clone Git et `install-local.sh` reste documentée dans le [README](../README.md).
