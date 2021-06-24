# Dotig

A dotfiles manager to quickly setup your machine & synchronize your dotfiles.

## Description

Dotig is a shell script, Bash actually, to manage your dotfiles and backup them with Git. If offers a menu or a CLI allowing you to:
* add new dotfiles (relative and absolute paths are supported) and create automatically the symbolic links
* update the symbolic links and remove the broken ones
* commit all changes
* push the changes
* pull your remote changes to keep your dotfiles up-to-date
* update the Git submodules (if you use them)
* remove the symlinks (by replacing them with a copy of your dotfiles)
* check for Dotig updates
* print Dotig version
* print Dotig help

The script also check your repo status to let you know if pull/push are needed or if your repo is dirty.

Dotig stands for Dot(files) + gi(t) (inverted). I wanted a short name to avoid creating an alias. I also wanted a name not used by other projects ("*dotman*" is common for example).

## Requirements

Dotig needs:
* [Git](https://git-scm.com/)
* GNU/Linux and GNU Coreutils

If you want to backup your dotfiles, and since you're here, I assume Git is not a problem.

Regarding GNU/Linux and GNU Coreutils:

* I tried to make Dotig portable by avoiding some GNU Coreutils but there may still be some left.
* Also, I do not have a Mac at my disposal to test and to make Dotig compatible.

So I prefer leave these requirements for now.

I also added a warning if you're not using Manjaro because I have not tested the script on other distributions for now.

## Install

Download `dotig` then make sure it is executable:

```bash
chmod +x dotig
```

## Usage

From the directory containing Dotig:
```bash
./dotig
```

Or, if it is in your `PATH`, simply:
```bash
dotig
```

Then, let you guide with the menu. Or, you can also use Dotig via CLI.

If it is the first time you run Dotig, you may want to use the `--verbose` option. See [CLI options](#options). It is not required, but this way you can understand what is done.

## CLI

If you want to use Dotig from CLI, you need to set the `DOTFILES` environment variable. See [Configuration](#configuration).
### Commands

|Commands|Usage|Description|
|---|---|---|
|`add`|`dotig add`<br />`dotig add <files>`|Add new dotfiles and create symlinks.|
|`update`|`dotig update`|Update symlinks and remove broken ones.|
|`rm`|`dotig rm`|Replace symlinks with the original files.|
|`commit`|`dotig commit`|Git commit all changes.|
|`push`|`dotig push`|Git push all changes.|
|`pull`|`dotig pull`|Git pull your remote changes.|
|`submodule`|`dotig submodule`|Update all your Git submodules.|
|`status`|`dotig status`|Show the repo status (dirty files or if push/pull is needed).|

### Options

|Options|Usage|Description|
|---|---|---|
|`-h`<br />`--help`|`dotig -h`<br />`dotig --help`|Show Dotig help.|
|`-ns`<br />`--no-status`|`dotig -ns`<br />`dotig --no-status`|Do not display the repo status when opening the Dotig menu.|
|`-v`<br />`--verbose`|`dotig -v`<br />`dotig --verbose`|Verbose mode. Explain what is done.|
|`--version`|`dotig --version`|Show Dotig version and check for new release.|

## Configuration

You can add Dotig manually to your `PATH` to execute it from everywhere or, according to your distribution, simply add the file to `$HOME/.local/bin` (which may be in your `PATH` by default).

In order for the script to remember your dotfiles directory, you may want to define an environment variable `DOTFILES` in your shell configuration files (like `~/.profile` for Bash or `~/.zshenv` for Zsh). It is also needed if you want to use Dotig from CLI.


```bash
export DOTFILES="$HOME/.dotfiles"
```

## License

This project is open-source and it is licensed under the [MIT license](./LICENSE).
