# Useful Scripts

Set of tools to be used on new system setup for Ubuntu 24.04

## Running the script

Environment installation script for Ubuntu 24.04:

```bash
sh ubuntu.sh
```

**Important:** do not run this with `sudo` or when you are switched to the root user.

## Table of Contents

- [Running the script](#running-the-script)
- [Installed software](#installed-software)
- [Post-installation tips](#post-installation-tips)
  - [Shortcuts](#shortcuts)
  - [Bash Profile](#bash-profile)
  - [Dual-Boot Time Issue](#dual-boot-time-issue)
  - [X11 Gestures](#x11-gestures)
  - [Database Deploy](#database-deploy)
- [Aliases](#aliases)
  - [PHP](#php)
  - [Node](#node)
  - [Magento](#magento)
  - [Other](#other)
  - [Special](#special)
    - [CERT](#cert)
    - [NGENSITE](#ngensite)
- [Laptop compatibility](#laptop-compatibility)

## Installed software

Development:
- Git
- PHP (8.0-8.3)
- Composer
- Node 22 + [n](https://www.npmjs.com/package/n) (to switch versions)
- MySQL Client (8.0 + MariaDB 10.11)
- Redis Server
- Elasticsearch 7
- Docker
- mkcert (Local SSL Certificates)

Browsers:
- Google Chrome
- Firefox (PPA)
- Epiphany (webkit "Gnome Web" browser)

Editors:
- SublimeText
- PhpStorm
- Vim

Messengers:
- Telegram
- Slack
- Skype

etc:
- `diodon` - clipboard manager
- `keepassxc` - password storage
- `guake` - custom terminal
- `shutter` - making and editing screenshots
- `obs-studio` - screen recording
- `curl` - tool to transfer data
- `htop` - process manager
- `mc` (Midnight Commander) - console file manager

## Post-installation tips

### Shortcuts

You can add shortcuts for installed programs to have immediate access.  
Add them in Settings: `Keyboard > "View and Customize Shortcuts" > "Custom Shortcuts"`

|         Program          | Command             | Suggested shortcut |
|:------------------------:|---------------------|--------------------|
| Diodon Clipboard Manager | `/usr/bin/diodon`   | Ctrl+Alt+H         |
|      Guake Terminal      | `/usr/bin/guake -t` | F1                 |

### Bash Profile

You can customize terminal output to show current Git branch when you-re inside the repository.  
Find and update respective block in `~/.bashrc`:

```bash
git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \[\033[01;35m\]$(git_branch)\[\033[00m\]\$ '
else
    ...
```

### Dual-Boot Time Issue

In case of dual-boot setup with Windows, run this command after installation to fix time sliding issue:

```bash
timedatectl set-local-rtc 1
```

### X11 Gestures

By default 3-finger gestures are not available in X11 session. To enable them install [X11 Gestures](https://extensions.gnome.org/extension/4033/x11-gestures/) extension.

[Touchegg](https://github.com/JoseExposito/touchegg?tab=readme-ov-file#ubuntu-debian-and-derivatives) app is also required:

```bash
sudo add-apt-repository ppa:touchegg/stable
sudo apt install touchegg
```

## Database Deploy

Use `bin/db_deploy.sh` script as a basis to deploy database dump files.

## Aliases

Several useful aliases were added to the `~/.bash_aliases` file:

### PHP

| Alias  | Description                                    |
|:------:|------------------------------------------------|
| PHP[X] | Switch CLI to [X] version of PHP, e.g. `PHP83` |
|  C[X]  | Switch Composer to [X] version, e.g. `C2`      |
|   XD   | Toggle Xdebug for FPM and CLI environments     |

### Node

| Alias | Description                            |
|:-----:|----------------------------------------|
| N[X]  | Switch Node to [X] version, e.g. `N20` |

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

### Special

|        Alias         | Description                                                                                                 |
|:--------------------:|-------------------------------------------------------------------------------------------------------------|
|   CERT example.com   | Generate SSL certificate for `example.com`, including `www.example.com`                                     |
| NGENSITE example.com | Links Nginx configuration for `example.com` into `sites-enabled` folder, enabling the config file inclusion |

## Laptop compatibility

In order to have proper S3 state suspend, check its support via terminal:

```bash
sudo dmesg | grep -i acpi | grep supports # Linux
powercfg /a                               # Windows
```

---

###### Inspired by [DefaultValue/ubuntu_post_install_scripts](https://github.com/DefaultValue/ubuntu_post_install_scripts)
