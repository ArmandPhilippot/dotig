# Dotig

A dotfiles manager to quickly setup your machine & synchronize your dotfiles.

## Description

Dotig is a shell script, Bash actually, to manage your dotfiles and backup them with Git. If offers a menu allowing you to:
* add new dotfiles (relative and absolute paths are supported)
* create automatically the symbolic links
* commit all changes
* push the changes
* pull your remote changes to keep your dotfiles up-to-date
* remove the symlinks (by replacing them with a copy of your dotfiles)
* check for Dotig updates

The script also check your repo status to let you know if pull/push are needed or if your repo is dirty.

Dotig stands for Dot(files) + gi(t) (inverted). I wanted a short name to avoid creating an alias. I also wanted a name not used by other projects: "*dotman*" is common, "*dotit*" is used by other tech companies ...

## Requirements

Dotig needs:
* Linux
* Git
* GNU Coreutils

If you want to backup your dotfiles, and since you're here, I assume Git is not a problem.

Regarding GNU Coreutils, if you're on Mac OS it can be problematic. That is why it is not supported for now.

Only Linux is supported, but I added a warning if you're not using Manjaro because I have not tested the script on other distributions for now.

## Install

Download `dotig.sh` then make sure it is executable:

```bash
chmod +x dotig.sh
```

## Usage

From the directory containing Dotig:
```bash
./dotig.sh
```

Or, if it is in your `PATH`, simply:
```bash
dotig
```

Then, let you guide with the menu.

## Configuration

You can add it manually to your `PATH` to execute it from everywhere or, according to your distribution, simply add it to `$HOME/.local/bin` (which may be in your `PATH` by default).

In order for the script to remember your dotfiles directory, you may want to define an environment variable `DOTFILES`. For example:

```bash
export DOTFILES="$HOME/.dotfiles"
```

## License

This project is open-source and it is licensed under the [MIT license](./LICENSE).
