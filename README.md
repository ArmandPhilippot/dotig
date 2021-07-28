# Dotig

![License](https://img.shields.io/github/license/ArmandPhilippot/dotig?color=blue&colorA=4c4f56&label=License&style=flat-square) ![Version](https://img.shields.io/github/package-json/v/ArmandPhilippot/dotig?color=blue&colorA=4c4f56&label=Version&style=flat-square)

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
* display a dirty files list by category (i.e. modified, deleted...)
* check for Dotig updates
* print Dotig version
* print Dotig help

The script also check your repo status to let you know if pull/push are needed or if your repo is dirty.

Dotig stands for Dot(files) + gi(t) (inverted). I wanted a short name to avoid creating an alias. I also wanted a name not used by other projects ("*dotman*" is common for example).

## Requirements

Dotig needs:
* [Git](https://git-scm.com/)
* Bash
* GNU/Linux
* GNU Coreutils
* `curl` (optional: used to check for Dotig updates)

If you want to backup your dotfiles, and since you're here, I assume Git is not a problem.

**Regarding GNU/Linux:** I do not have a Mac at my disposal to test and to make Dotig compatible. Also, I have not yet tested on BSD systems.

**Regarding GNU Coreutils:** I tried to make Dotig portable by avoiding some GNU Coreutils but there are still incompatible commands or options.

## Structure

Dotig is based on [XDG Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) with extra environment variables to make the tool more portable.

If you have not set these environment variables and if your distribution does not provide some default, Dotig define some defaults for you. Then, it creates the appropriate directories inside your dotfiles repository when you add some dotfiles.

`$DOTFILES` corresponds to your dotfiles repository. See [Configuration](#configuration).

|(Custom) XDG Specification|`$HOME` default paths|Repo paths|
|---|---|---|
|`XDG_BIN_HOME`|`~/.local/bin`|`$DOTFILES/home/xdg_bin`|
|`XDG_CACHE_HOME`|`~/.cache`|`$DOTFILES/home/xdg_cache`|
|`XDG_CONFIG_HOME`|`~/.config`|`$DOTFILES/home/xdg_config`|
|`XDG_DATA_HOME`|`~/.local/share`|`$DOTFILES/home/xdg_data`|
|`XDG_LIB_HOME`|`~/.local/lib`|`$DOTFILES/home/xdg_lib`|
|`XDG_STATE_HOME`|`~/.local/state`|`$DOTFILES/home/xdg_state`|

This is useful if you use different paths on two different distributions. For example:
* your first distribution can use `XDG_CONFIG_HOME=$HOME/.config`
* the second can use `XDG_CONFIG_HOME=$HOME/.local/etc`

Dotig can also copy files that are not in XDG paths. In this case, it will add your repository path before the file path. With one exception for HOME: `/home/username` is replaced with `/home`.

For example:
|File path|Copy path|
|---|---|
|`~/.ssh/config`|`$DOTFILES/home/.ssh/config`|
|`/etc/nanorc`|`$DOTFILES/etc/nanorc`|

If you add files that are not in your `$HOME`, Dotig will copy them but no symbolic link will be created. It does not use administrator rights. So, you can backup these files but you will have to manage their integration yourself.

The behavior is the same for updating and deleting symlinks.

You can also safely put some files (like a custom init script or a readme) at the root of your dotfiles repository. Dotig won't touch them except for Git features:
* they will be included in your repo status.
* if they are modified and you use Dotig to make a commit, they will be added to this commit.
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

If you want to use Dotig from CLI, it is recommended to set the `DOTFILES` environment variable. See [Configuration](#configuration).
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

### Global Options

|Options|Usage|Description|
|---|---|---|
|`-h`<br />`--help`|`dotig -h`<br />`dotig --help`|Show Dotig help.|
|`-ns`<br />`--no-status`|`dotig -ns`<br />`dotig --no-status`|Do not display the repo status when opening the Dotig menu.|
|`-p`<br />`--private`|`dotig -p`<br />`dotig --private`|Use your private dotfiles repository instead of the default one.|
|`-v`<br />`--verbose`|`dotig -v`<br />`dotig --verbose`|Verbose mode. Explain what is done.|
|`--version`|`dotig --version`|Show Dotig version and check for new release.|

Some options, like `--verbose` or `--private` can be used before or after the command. Result will be the same.

Example:
```
dotig -v <command>
dotig <command> -v
```

### Other options

Each command also has its own options. You can see them with: `dotig <command> -h` or `dotig <command> --help`.

## Configuration

You can add Dotig manually to your `PATH` to execute it from everywhere or, according to your distribution, simply add the file to `$HOME/.local/bin` (which may be in your `PATH` by default).

In order for the script to remember your dotfiles directory, you may want to define an environment variable `DOTFILES` in your shell configuration files (like `~/.profile` for Bash or `~/.zshenv` for Zsh).

Example:

```bash
export DOTFILES="$HOME/.dotfiles"
```

Sometimes we also need to manage secrets (i.e. credentials for example) or we do not want to share some dotfiles. So Dotig allows you to manage a secondary repository. To do so, you need to define an environment variable `DOTFILES_PRIVATE` the same way as `DOTFILES`.

Example:

```bash
export DOTFILES_PRIVATE="$HOME/.private-dotfiles"
```

## Motivation

I know it already exists a lot of solution to manage the dotfiles like bare repository, [chezmoi](https://github.com/twpayne/chezmoi) or [dotbot](https://github.com/anishathalye/dotbot) for example. I tested some of them but I'm not satisfied. So, I decided to create my own script to manage **my dotfiles the way I wanted**. As the features grew, I thought that the script could be helpful to others. So, Dotig is born.

At first, I wanted a solution that include Git and GNU Stow. Finally, I realized that I didn't need GNU Stow. It was easier to create the symlinks "manually" and it allowed me to keep the desired structure. And, that way, it takes away a dependency and makes the script more portable.

However, for now, as you can see in [Requirements](#requirements), the compatibility with other OS is not guaranteed. But, it is a possible development.

## Disclaimer

### Compatibility

I have only tested on Manjaro Linux 21, Debian 10, Ubuntu 20 and Fedora 34. So:
* maybe there are some requirements not listed
* a different behavior is possible depending on your distribution and the version of the tools used (options can be different or missing)

### Migration

Dotig does not manage migration from or to another tool. So, if your dotfiles repository already contains some paths you will have to adjust the paths manually to keep your repo clean.

**For example:** if you have a `$DOTFILES/.config/nano/nanorc`, you may want to change the path to `$DOTFILES/home/xdg_config/nano/nanorc` (and vice versa if you want to switch from Dotig to another tool).

## License

This project is open-source and it is licensed under the [MIT license](./LICENSE).
