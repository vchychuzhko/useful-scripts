# Useful Scripts

Set of tools to be used on new system setup for Ubuntu 24.04

## Running the script

Environment installation script for Ubuntu 24.04:

```bash
curl -fsSL https://raw.githubusercontent.com/vchychuzhko/useful-scripts/refs/heads/master/ubuntu.sh | bash
```

**Important:** do not run this with `sudo` or when you are switched to the root user.

## Table of Contents

- [Installed software](#installed-software)
- [Post-installation tips](#post-installation-tips)
  - [Shortcuts](#shortcuts)
  - [Bash Profile](#bash-profile)
  - [Dual-Boot Time Issue](#dual-boot-time-issue)
- [Database Deploy](#database-deploy)
- [Aliases](#aliases)
  - [PHP](#php)
  - [Node](#node)
  - [Magento](#magento)
  - [Other](#other)
  - [Custom](#custom)

## Installed software

Development:
- Git
- PHP (8.0-8.4)
- Composer
- Node 24 + [nvm](https://www.nvmnode.com/) (to switch versions, 16-24 by default)
- MySQL Client (8.0 + MariaDB 10.11)
- Redis
- Elasticsearch 7
- Docker
- mkcert (Local SSL Certificates)

Browsers:
- Google Chrome
- Epiphany (webkit "Gnome Web" browser)

Editors:
- SublimeText
- PhpStorm
- Vim

Messengers:
- Telegram
- Slack

Tools
- Guake - terminal
- KeePassXC - passwords manager
- Gradia - screenshots tool
- OBS Studio - screen recorder
- Pinta - image editor

etc:
- htop
- gufw (GUI for firewall)
- mc (Midnight Commander)
- pv (Pipe Viewer)

## Post-installation tips

### Shortcuts

You can add shortcuts for installed programs to have immediate access.  
Add them in Settings: Keyboard > View and Customize Shortcuts > Custom Shortcuts

|         Program          | Command             | Suggested shortcut |
|:------------------------:|---------------------|--------------------|
|      Guake Terminal      | `/usr/bin/guake -t` | F1                 |

### Bash Profile

You can customize terminal output to show current Git branch when you're inside the repository.  
Find and update respective block in `~/.bashrc`:

```bash
git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;34m\]\w \[\033[01;35m\]$(git_branch)\[\033[00m\]\$ '
else
    ...
```

### Dual-Boot Time Issue

In case of dual-boot setup with Windows, run this command after installation to fix time sliding issue:

```bash
timedatectl set-local-rtc 1
```

## Recommended Extensions

- [Clipboard History](https://extensions.gnome.org/extension/4839/clipboard-history/)
- [Tasks in panel](https://extensions.gnome.org/extension/8642/tasks-in-panel/)

## Database Deploy

Use `bin/db_deploy.sh` script as a basis to deploy Magento database files.

## Aliases

Several useful aliases were added to the `~/.bash_aliases` file:

### PHP

| Alias  | Description                                                         |
|:------:|---------------------------------------------------------------------|
| PHP[X] | Switch CLI to [X version](#installed-software) of PHP, e.g. `PHP83` |
| C[1,2] | Switch Composer version, e.g. `C2`                                  |
|   XD   | Toggle Xdebug for FPM and CLI environments                          |

### Node

| Alias | Description                                                         |
|:-----:|---------------------------------------------------------------------|
| N[X]  | Switch Node to [X version](#installed-software) of Node, e.g. `N22` |

### Magento

| Alias | Command                            |
|:-----:|------------------------------------|
|  SU   | `php bin/magento setup:upgrade`    |
|  DI   | `php bin/magento setup:di:compile` |
|  CC   | `php bin/magento cache:clean`      |
|  RI   | `php bin/magento indexer:reindex`  |
|  RS   | `php bin/magento indexer:status`   |

### Other

|  Alias   | Description                         |
|:--------:|-------------------------------------|
|   MY80   | Login to MySQL container as admin   |
|   MA10   | Login to MariaDB container as admin |
|    AP    | Restart Apache                      |
|    NG    | Restart Nginx                       |
|    ES    | Start/Restart Elasticsearch         |
|  ESOFF   | Stop Elasticsearch                  |

### Custom

|        Alias         | Description                                                                                                 |
|:--------------------:|-------------------------------------------------------------------------------------------------------------|
|   CERT example.com   | Generate SSL certificate for `example.com`, including `www.example.com`                                     |
| NGENSITE example.com | Links Nginx configuration for `example.com` into `sites-enabled` folder, enabling the config file inclusion |

---

###### Inspired by [DefaultValue/ubuntu_post_install_scripts](https://github.com/DefaultValue/ubuntu_post_install_scripts)
