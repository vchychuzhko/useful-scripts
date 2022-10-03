# Useful Scripts

Set of tools to be used on new system setup for Ubuntu 22.04

## Running the script

Automated environment installation script for Ubuntu 22.04:

```bash
sh ubuntu_22.04.sh
```

**Important:** do not run this with `sudo` or when you are switched to the root user.

## Installed software

Development:
- Git
- PHP (7.4-8.1)
- Composer
- Node 18 + [n](https://www.npmjs.com/package/n) (to switch versions)
- MySQL Client (5.6-8.0 + MariaDB 10.4)
- Redis Server
- Elasticsearch 7
- Docker
- mkcert (generating SSL certificates for local development)

Browsers:
- Google Chrome

*Also take a look at webkit "Gnome Web" browser ([Epiphany](https://flathub.org/apps/details/org.gnome.Epiphany)).*

Editors:
- SublimeText
- PHPStorm
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
- `gnome-tweaks` - ubuntu fine-tuning
- `curl` - tool to transfer data
- `htop` - process manager
- `mc` (Midnight Commander) - console file manager

---

###### Inspired by [DefaultValue/ubuntu_post_install_scripts](https://github.com/DefaultValue/ubuntu_post_install_scripts)
