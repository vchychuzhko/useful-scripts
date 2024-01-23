# Useful Scripts

Set of tools to be used on new system setup for Ubuntu 22.04

## Running the script

Environment installation script for Ubuntu 22.04:

```bash
sh ubuntu_22.04.sh
```

**Important:** do not run this with `sudo` or when you are switched to the root user.

## Installed software

Development:
- Git
- PHP (7.4-8.3)
- Composer
- Node 18 + [n](https://www.npmjs.com/package/n) (to switch versions)
- MySQL Client (5.6-8.0 + MariaDB 10.4)
- Redis Server
- Elasticsearch 7
- Docker
- mkcert (generating SSL certificates for local development)

Browsers:
- Google Chrome
- Firefox (PPA)
- Epiphany (webkit "Gnome Web" browser)

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

## Post-installation tips

### Shortcuts

You can add shortcuts for installed programs to have immediate access.  
Add them in Settings: `Keyboard > "View and Customize Shortcuts" > "Custom Shortcuts"`

| Program | Command | Suggested shortcut |
| :---: | --- | --- |
| Diodon Clipboard Manager | `/usr/bin/diodon` | Ctrl+Alt+H |
| Guake Terminal | `/usr/bin/guake -t` | F1 |

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

## Binaries

### Database Deploy

Use `bin/db_deploy.sh` script as a basis to deploy database dump files.

### Elasticsearch cleanup

Use `bin/es_remove_unaliased.sh` script to remove unaliased indexes from elastic database.

## Laptop compatibility

In order to have proper S3 state suspend, check its support via terminal:

```bash
sudo dmesg | grep -i acpi | grep supports # Linux
powercfg /a                               # Windows
```

---

###### Inspired by [DefaultValue/ubuntu_post_install_scripts](https://github.com/DefaultValue/ubuntu_post_install_scripts)
