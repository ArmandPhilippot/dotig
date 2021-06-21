#!/bin/bash
#
# Dotig
# A dotfiles manager to quickly setup your machine & synchronize your dotfiles
# with Git.
#
# Requirements: Git and GNU Coreutils.
# Author: Armand Philippot <https://www.armandphilippot.com/>
# URL: https://github.com/ArmandPhilippot/dotig

###############################################################################
#
# The MIT License (MIT)

# Copyright (c) 2021 Armand Philippot

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
###############################################################################

set -e

###############################################################################
# Variables
###############################################################################
DOTIG_VERSION="0.1.0"
DOTIG_LOGO=$(
  cat <<-EOF
#######################################
##      ____        _   _            ##
##     |  _ \  ___ | |_(_) __ _      ##
##     | | | |/ _ \| __| |/ _  |     ##
##     | |_| | (_) | |_| | (_| |     ##
##     |____/ \___/ \__|_|\__, |     ##
##                        |___/      ##
##                                   ##
#######################################
EOF
)
DOTIG_PATH=""

# Colors
_error_color=$(printf '\e[31m')
_success_color=$(printf '\e[32m')
_warning_color=$(printf '\e[33m')
_choice_color=$(printf '\e[34m')
_output_color=$(printf '\e[35m')
_no_color=$(printf '\e[0m')

###############################################################################
# Helpers
###############################################################################

display_logo() {
  printf "%s\n\n" "$DOTIG_LOGO"
}

error_callback() {
  printf "%sAn unexpected error occurred.%s Exit.\n" "$_error_color" "$_no_color"
  exit 1
}

set_path() {
  local _path
  printf "Set the path: " >&2
  read -r _path

  while [ ! -d "$_path" ]; do
    printf "%sError:%s It is not a directory. Please enter a valid path: " "$_error_color" "$_no_color"
    read -r _path
  done

  eval "$1=$_path"
}

is_correct_path() {
  [ $# -ne 1 ] && error_callback

  local _validation
  local _valid_path
  local -n _path=$1

  while true; do
    printf "Is %s%s%s correct? %s[y/n]%s " "$_output_color" "$_path" "$_no_color" "$_choice_color" "$_no_color"
    read -r _validation
    case $_validation in
    [yY])
      break
      ;;
    [nN])
      set_path _valid_path
      _path=$_valid_path
      ;;
    *) printf "%sError:%s please enter %s[y]%ses or %s[n]%so." "$_error_color" "$_no_color" "$_choice_color" "$_no_color" "$_choice_color" "$_no_color" ;;
    esac
  done
}

###############################################################################
# Git Helpers
# Used to init Git, check repo status and to commit, push & pull (Git options)
###############################################################################

get_current_branch() {
  git -C "$DOTIG_PATH" symbolic-ref --quiet --short HEAD
}

get_branch_upstream() {
  local _git_branch
  _git_branch=$(get_current_branch)
  git -C "$DOTIG_PATH" config branch."$_git_branch".remote > /dev/null 2>&1
}

get_existing_remotes() {
  git -C "$DOTIG_PATH" remote
}

update_remote_tracking() {
  git -C "$DOTIG_PATH" fetch
}

get_local_commit() {
  git -C "$DOTIG_PATH" rev-parse --verify -q HEAD
}

get_remote_commit() {
  git -C "$DOTIG_PATH" rev-parse --verify -q FETCH_HEAD
}

get_common_ancestor() {
  local _local_commit=$1
  local _remote_commit=$2

  [ "$_local_commit" ] &&  git -C "$DOTIG_PATH" merge-base HEAD "$_remote_commit"
}

is_repo_up_to_date() {
  local _local_commit=$1
  local _remote_commit=$2

  [ "$_local_commit" = "$_remote_commit" ]
}

is_pull_needed() {
  local _local_commit=$1
  local _common_ancestor=$2

  [ "$_local_commit" = "$_common_ancestor" ]
}

is_push_needed() {
  local _remote_commit=$1
  local _common_ancestor=$2

  [ "$_remote_commit" = "$_common_ancestor" ]
}

get_dirty_files_count() {
  git -C "$DOTIG_PATH" status --porcelain | wc -l
}

is_repo_dirty() {
  local _dirty_files_count
  _dirty_files_count=$(get_dirty_files_count)

  [ "$_dirty_files_count" -ne 0 ]
}

get_untracked_files_count() {
  git -C "$DOTIG_PATH" status --porcelain | grep -c "^??"
}

get_staged_files_count() {
  git -C "$DOTIG_PATH" status --porcelain | grep -c "^[A|M]"
}

get_deleted_files_count() {
  git -C "$DOTIG_PATH" status --porcelain | grep -c "^.D"
}

get_renamed_files_count() {
  git -C "$DOTIG_PATH" status --porcelain | grep -c "^R"
}

get_modified_files_count() {
  git -C "$DOTIG_PATH" status --porcelain | grep -c "^.M"
}

get_unmerged_files_count() {
  git -C "$DOTIG_PATH" ls-files --unmerged | wc -l
}

get_stashed_files_count() {
  git -C "$DOTIG_PATH" stash list | wc -l
}

get_unpushed_commits() {
  local _current_branch
  local _upstream_branch

  _current_branch=$(get_current_branch)
  _upstream_branch=$(git -C "$DOTIG_PATH" config branch."$_current_branch".remote)

  git -C "$DOTIG_PATH" log --oneline "$_upstream_branch"/"$_current_branch"..HEAD
}

###############################################################################
# Safety Checks
# Do not execute Dotig if operating system is not supported or if Git is not
# installed.
###############################################################################

is_linux() {
  [ "$OSTYPE" = "linux-gnu" ]
}

is_manjaro() {
  if [ -f "/etc/os-release" ]; then
    # shellcheck disable=SC1091
    . "/etc/os-release"
    [ "$ID" ] && [ "$ID" = "manjaro" ]
  elif [ -f "/etc/lsb-release" ]; then
    # shellcheck disable=SC1091
    . "/etc/lsb-release"
    [ "$DISTRIB_ID" ] && [ "$DISTRIB_ID" = "ManjaroLinux" ]
  fi
}

check_os() {
  printf "Identifying the operating system...\n"

  if is_linux; then
    printf "%sSuccess:%s Linux is supported.\n" "$_success_color" "$_no_color"
  else
    printf "%sError:%s Linux is the only supported operating system.\n" "$_error_color" "$_no_color"
    printf "Exit.\n"
    exit 1
  fi

  if ! is_manjaro; then
    printf "%sWarning:%s Dotig has only been tested with Manjaro.\n" "$_warning_color" "$_no_color"
  fi
}

is_git_installed() {
  [ -x "$(command -v git)" ]
}

check_commands() {
  printf "Checking installed programs...\n"

  if is_git_installed; then
    printf "%sSuccess:%s Git is installed.\n" "$_success_color" "$_no_color"
  else
    printf "%sError:%s Dotig needs Git to function properly.\n" "$_error_color" "$_no_color"
    printf "Please install it before using this program.\n"
    printf "Exit.\n"
    exit 1
  fi
}

check_requirements() {
  printf "Checking requirements...\n"
  check_os
  check_commands
  printf "%sSuccess:%s Requirements checked!\n" "$_success_color" "$_no_color"
  printf "Let's continue.\n\n"
}

###############################################################################
# Repo configuration
# Check if $DOTFILES is defined and if it is a repo. If not, set both.
###############################################################################

set_dotfiles_dir() {
  local _path

  set_path _path
  is_correct_path _path

  eval "$1=$_path"
}

is_dotfiles_dir_set() {
  local _dotfiles_path

  printf "For conveniance, Dotig uses a \$DOTFILES variable to determine the dotfiles backup path. If it is not set, you may want to declare it for future use.\n\n"
  printf "Checking if a \$DOTFILES variable is set...\n"

  if [ ! "$DOTFILES" ]; then
    printf "%sWarning:%s The \$DOTFILES variable is not set.\n" "$_warning_color" "$_no_color"
    set_dotfiles_dir _dotfiles_path
  elif [ ! -d "$DOTFILES" ]; then
    printf "%sWarning:%s The \$DOTFILES variable does not seem to match a directory.\n" "$_warning_color" "$_no_color"
    set_dotfiles_dir _dotfiles_path
  else
    printf "%sSuccess:%s Found \$DOTFILES variable.\n" "$_success_color" "$_no_color"
    _dotfiles_path=$DOTFILES
    is_correct_path _dotfiles_path
  fi

  eval "$1=$_dotfiles_path"
}

is_valid_remote_name() {
  [ $# -ne 2 ] && error_callback

  case $2 in
    *"$1"* ) return 0 ;;
    *) return 1 ;;
  esac
}

ask_remote_name() {
  local _git_remotes
  local _branch_name
  local _choice

  _git_remotes=$(get_existing_remotes)
  _branch_name=$(get_current_branch)

  printf "%sWarning:%s Your repo contains multiple remotes:\n" "$_warning_color" "$_no_color"
  printf "%s\n" "$_git_remotes"
  printf "Choose the remote to use for %s: " "${_output_color}${_branch_name}${_no_color}"
  read -r _choice

  while ! is_valid_remote_name "$_choice" "$_git_remotes"; do
    printf "\n%sError:%s Remote name invalid.\n" "$_error_color" "$_no_color"
    printf "Use one of:\n"
    printf "%s\n" "${_choice_color}${_git_remotes}${_no_color}"
    printf "Enter a valid remote name: "
    read -r _choice
  done

  printf "\n"

  eval "$1=$_choice"
}

set_branch_upstream() {
  local _local_branch
  local _git_remotes
  local _remote_name
  local _remote_branch

  _local_branch=$(get_current_branch)
  _git_remotes=$(get_existing_remotes)

  if [ "$(printf "%s\n" "$_git_remotes" | wc -l)" -gt 1 ]; then
    ask_remote_name _remote_name
  else
    _remote_name=$_git_remotes
  fi

  git -C "$DOTIG_PATH" pull "$_remote_name" "$_local_branch"

  _remote_branch=$(git -C "$DOTIG_PATH" ls-remote --symref origin HEAD | head -1 | sed 's@ref: refs/heads/@@' | cut -f1)

  git -C "$DOTIG_PATH" fetch --set-upstream "$_remote_name" "$_remote_branch"

  printf "%sSuccess:%s Upstream set.\n" "$_success_color" "$_no_color"
}

is_upstream_set() {
  if ! get_branch_upstream; then
    set_branch_upstream
  fi
}

is_valid_remote_url() {
  [ $# -ne 1 ] && error_callback

  local _remote_url=$1

  case $_remote_url in
    "https"* | "git@"*) return 0 ;;
    *) return 1 ;;
  esac
}

is_remote_exists() {
  [ $# -ne 1 ] && error_callback

  local -n _valid_remote=$1

  printf "\nChecking if this URL exist. Your SSH passphrase can be requested.\n"

  if ! git ls-remote "$_valid_remote" > /dev/null 2>&1; then
    while ! git ls-remote "$_valid_remote" > /dev/null 2>&1; do
      printf "%sError:%s This remote URL does not exist.\n" "$_error_color" "$_no_color"
      printf "Enter a valid remote URL: "
      read -r _valid_remote
    done
  fi
}

set_remote() {
  local _remote

  printf "Dotig needs to know your remote to perform some actions (status, push, pull).\n"
  printf "Please enter your remote address: "
  read -r _remote

  while ! is_valid_remote_url "$_remote"; do
    printf "\n%sError:%s The remote URL is not valid. URL must starts with 'https' or 'git@'.\n" "$_error_color" "$_no_color"
    printf "Please enter a valid remote address: "
    read -r _remote
  done

  is_remote_exists _remote
  git -C "$DOTIG_PATH" remote add origin "$_remote"
  printf "%sSuccess:%s Remote set.\n" "$_success_color" "$_no_color"
}

is_remote_set() {
  if ! git -C "$DOTIG_PATH" config --get-regexp '^remote\.' > /dev/null 2>&1; then
    printf "\nDotig is a Git repository but the remote is not set.\n"
    set_remote
  fi
}

init_git() {
  git -C "$DOTIG_PATH" init
  printf "\n"
  set_remote
  set_branch_upstream
}

is_git_repo() {
  git -C "$DOTIG_PATH" rev-parse --git-dir > /dev/null 2>&1
}

is_git_configured() {
  local _choice

  printf "\nChecking if Git is configured...\n"

  if ! is_git_repo; then
    printf "\n%sWarning:%s Your dotfiles directory is not a Git repository.\n" "$_warning_color" "$_no_color"
    while true; do
      printf "Do you want to configure it? %s[y/n]%s " "$_choice_color" "$_no_color"
      read -r _choice
      case $_choice in
        [yY])
          init_git
          return 0
          ;;
        [nN])
          printf "\n%sWarning:%s Dotig needs a Git repository to properly function. Please configure it manually before using this program.\n" "$_warning_color" "$_no_color"
          printf "Exit.\n"
          exit
          ;;
        *) printf "%sError:%s Enter %s[y]%ses or %s[n]%sno" "$_error_color" "$_no_color" "$_choice_color" "$_no_color" "$_choice_color" "$_no_color" ;;
      esac
    done
  else
    is_remote_set
    is_upstream_set
  fi
}

check_dotfiles_repo() {
  is_dotfiles_dir_set DOTIG_PATH
  is_git_configured
  printf "%sSuccess:%s Your dotfiles repo is ready.\n" "$_success_color" "$_no_color"
}

###############################################################################
# Repo Status
# Call git to obtain some info about the repo status and display these info.
###############################################################################

get_expanded_status() {
  local _untracked_files_count
  local _staged_files_count
  local _deleted_files_count
  local _renamed_files_count
  local _modified_files_count
  local _unmerged_files_count
  local _stashed_files_count
  local _expanded_status

  _untracked_files_count=$(get_untracked_files_count) || true
  _staged_files_count=$(get_staged_files_count) || true
  _deleted_files_count=$(get_deleted_files_count) || true
  _renamed_files_count=$(get_renamed_files_count) || true
  _modified_files_count=$(get_modified_files_count) || true
  _unmerged_files_count=$(get_unmerged_files_count) || true
  _stashed_files_count=$(get_stashed_files_count) || true

  _expanded_status="You have:\n"
  [ "$_untracked_files_count" -gt 0 ] && _expanded_status+="* $_untracked_files_count untracked files\n"
  [ "$_staged_files_count" -gt 0 ] && _expanded_status+="* $_staged_files_count staged files\n"
  [ "$_deleted_files_count" -gt 0 ] && _expanded_status+="* $_deleted_files_count deleted files\n"
  [ "$_renamed_files_count" -gt 0 ] && _expanded_status+="* $_renamed_files_count renamed files"
  [ "$_modified_files_count" -gt 0 ] && _expanded_status+="* $_modified_files_count modified files\n"
  [ "$_unmerged_files_count" -gt 0 ] && _expanded_status+="* $_unmerged_files_count unmerged files\n"
  [ "$_stashed_files_count" -gt 0 ] && _expanded_status+="* $_stashed_files_count stashed files\n"

  printf "%b\n" "$_expanded_status"
}

get_repo_status() {
  local _local_commit
  local _remote_commit
  local _common_ancestor

  printf "\nChecking status...\n"
  printf "Your SSH passphrase can be requested.\n"
  update_remote_tracking

  _local_commit=$(get_local_commit) || true
  _remote_commit=$(get_remote_commit) || true
  _common_ancestor=$(get_common_ancestor "$_local_commit" "$_remote_commit") || true

  if is_repo_up_to_date "$_local_commit" "$_remote_commit"; then
    printf "Status: %sup-to-date!%s\n" "$_success_color" "$_no_color"
  else
    is_pull_needed "$_local_commit" "$_common_ancestor" && printf "Status: %spull needed!%s\n" "$_warning_color" "$_no_color"
    is_push_needed "$_remote_commit" "$_common_ancestor" && printf "Status: %spush needed!%s\n" "$_warning_color" "$_no_color"
  fi

  if is_repo_dirty; then
    printf "Status: %sdirty repo!%s\n" "$_warning_color" "$_no_color"
    get_expanded_status
  else
    printf "Status: %sclean repo!%s\n\n" "$_success_color" "$_no_color"
  fi
}

###############################################################################
# Dotig options
# Allow user to check current version of Dotig and to check for updates.
###############################################################################

print_version() {
  printf "\nYour Dotig version is: %s\n" "$DOTIG_VERSION"
  return_menu
}

get_latest_release() {
  curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/ArmandPhilippot/dotig/releases/latest
}

check_dotig_updates() {
  local _latest_release
  local _tag_name
  local _new_version
  local _download_zip
  local _download_link
  local _not_found

  _latest_release=$(get_latest_release)
  _not_found=$(printf "%s" "$_latest_release" | { grep -Po '"message": "Not Found"' || true; })

  if [ "$_not_found" ] ; then
    printf "\n%sError:%s could not find any release...\n" "$_error_color" "$_no_color"
  else
    _tag_name=$(printf "%s" "$_latest_release" | grep -Po '"tag_name":.*?[^\\]",')
    _new_version=$(printf "%s" "$_tag_name" | grep -Po '(?=v).*(?=",)' | sed 's/^v//')

    if [ "$_new_version" = "$DOTIG_VERSION" ]; then
      printf "\n%sSuccess:%s Your Dotig version is up to date!\n" "$_success_color" "$_no_color"
    else
      _download_zip=$(printf "%s" "$_latest_release" | grep -Po '"zipball_url":.*?[^\\]",')
      _download_link=$(printf "%s" "$_download_zip" | grep -Po 'http.*(?=",)')

      printf "\n%sWarning:%s Your Dotig version is outdated!\n" "$_warning_color" "$_no_color"
      printf "A new version is available: %s\n" "$_new_version"
      printf "You can download it here: %s\n" "$_download_link"
    fi
  fi

  return_menu
}

###############################################################################
# Symlinking options
# Main feature of Dotig: handle backup of dotfiles and symlinking.
###############################################################################

get_absolute_path() {
  [ $# -ne 1 ] && error_callback

  local -n _file=$1
  local _absolute_path

  case $_file in
  /*) _absolute_path=$_file;;
  \~/*) _absolute_path="$HOME/${_file:2}" ;;
  ./*) _absolute_path="$(pwd)/${_file:2}" ;;
  *) _absolute_path="$(pwd)/$_file" ;;
  esac

  eval "$1=$_absolute_path"
}

print_diff() {
  local _home_dotfile=$1
  local _backup_dotfile=$2
  local _filename
  local _column_width=$(("$COLUMNS" / 2))
  local _padding
  local _padding_lenght
  local _divider

  _filename=$(basename "$_home_dotfile")
  _padding=$(printf '%*s' "$COLUMNS" "")
  _padding_lenght=$((_column_width - ${#HOME}))
  _divider=${_padding// /=}

  if diff -q "$_home_dotfile" "$_backup_dotfile" > /dev/null 2>&1; then
    printf "\nBoth files are identical."
  else
    printf "\nThe two files are different. See the diff of %s:\n\n" "${_output_color}${_filename}${_no_color}"
    printf "%s%0.${_padding_lenght}s%s\n" "$HOME" "$_padding" "$DOTIG_PATH";
    printf "%s\n" "$_divider";
    command diff --color -y --width=$COLUMNS -t --suppress-common-lines "$_home_dotfile" "$_backup_dotfile" || [ $? -eq 1 ]
  fi
}

print_handle_duplicate_menu() {
  printf "%s[1]%s Show diff\n" "$_choice_color" "$_no_color"
  printf "%s[2]%s Use %s (delete the other)\n" "$_choice_color" "$_no_color" "${_output_color}${_home_dotfile}${_no_color}"
  printf "%s[3]%s Use %s (delete the other)\n" "$_choice_color" "$_no_color" "${_output_color}${_backup_dotfile}${_no_color}"
  printf "%s[4]%s Skip this file\n" "$_choice_color" "$_no_color"
}

handle_duplicate() {
  local _choice
  local _home_dotfile=$1
  local _backup_dotfile=$2

  printf "%sWarning:%s A file with the same name already exists.\n" "$_warning_color" "$_no_color"

  [ -h "$_backup_dotfile" ] && printf "%sWarning:%s %s is a symlink.\n" "$_warning_color" "$_no_color" "${_output_color}${_backup_dotfile}${_no_color}"
  [ -h "$_home_dotfile" ] && printf "%sWarning:%s %s is a symlink.\n" "$_warning_color" "$_no_color" "${_output_color}${_home_dotfile}${_no_color}"

  printf "How do you want to proceed?\n"

  while true; do
    print_handle_duplicate_menu
    printf "Your choice: "
    read -r _choice

    case $_choice in
      1)
        print_diff "$_home_dotfile" "$_backup_dotfile"
        printf "\n"
        ;;
      2)
        printf "Deleting %s and creating symlink...\n" "${_output_color}${_backup_dotfile}${_no_color}"
        mv -f "$_home_dotfile" "$_backup_dotfile"
        ln -s "$_backup_dotfile" "$_home_dotfile"
        printf "Done.\n"
        break
        ;;
      3)
        printf "Deleting %s and creating symlink...\n" "${_output_color}${_home_dotfile}${_no_color}"
        rm "$_home_dotfile"
        ln -s "$_backup_dotfile" "$_home_dotfile"
        printf "Done.\n"
        break
        ;;
      4)
        printf "%sSkipped:%s %s\n" "$_warning_color" "$_no_color" "$_home_dotfile"
        break
        ;;
      *) printf "%sError:%s choose between %s[1]%s, %s[2]%s, %s[3]%s or %s[4]%s.\n" "$_error_color" "$_no_color" "$_choice_color" "$_no_color" "$_choice_color" "$_no_color" "$_choice_color" "$_no_color" "$_choice_color" "$_no_color"
    esac
  done
}

add_dotfiles() {
  local _dotfiles
  local _dest

  printf "\nEnter the dotfiles names: "
  read -r -e -a _dotfiles

  for _dotfile in "${_dotfiles[@]}"; do
    get_absolute_path _dotfile
    _dest="$DOTIG_PATH/home${_dotfile#$HOME}"
    if [ -f "$_dest" ]; then
      handle_duplicate "$_dotfile" "$_dest"
    else
      mkdir -p "$(dirname "$_dest")"
      mv "$_dotfile" "$_dest"
      ln -s "$_dest" "$_dotfile"
      printf "%sSuccess:%s %s moved and symlink created.\n" "$_success_color" "$_no_color" "$_dotfile"
    fi
  done

  return_menu
}

get_submodules_path() {
  # shellcheck disable=SC2016
  git -C "$DOTIG_PATH" submodule -q foreach 'printf ${sm_path}"\n"'
}

find_cmd() {
  local _find_cmd
  local _exclude_dirs=()
  local _tmp

  _tmp=$(mktemp "${TMPDIR:-/tmp}/dotig.XXXXXX")
  get_submodules_path > "$_tmp"

  while IFS='' read -r line; do _exclude_dirs+=("$line"); done < "$_tmp"

  rm "$_tmp"
  _exclude_dirs+=('.git')

  _find_cmd=( find "$DOTIG_PATH" -mindepth 2 \( -type f -o -type l \) )

  for _exclude_dir in "${_exclude_dirs[@]}"; do
    _find_cmd+=( -not \( -path "$DOTIG_PATH/${_exclude_dir}/*" -prune \) )
  done
  _find_cmd+=( -print )

  "${_find_cmd[@]}"
}

handle_update_target() {
  [ $# -ne 3 ] && error_callback

  local _file=$1
  local _symlink=$2
  local _target=$3
  local _extra_info=""

  [ -h "$_file" ] && _extra_info=" (also a symlink)"

  printf "\n%sWarning:%s A symlink exists but its target does not match your dotfile backup:\n" "$_warning_color" "$_no_color"
  printf "* Symlink: %s\n" "${_output_color}${_symlink}${_no_color}"
  printf "* Symlink target: %s\n" "${_output_color}${_target}${_no_color}"
  printf "* Dotfile backup%s: %s\n" "$_extra_info" "${_output_color}${_file}${_no_color}"

  printf "How do you want to proceed?\n"
  printf "%s[1]%s Update the symlink\n" "$_choice_color" "$_no_color"
  printf "%s[2]%s Skip this file\n" "$_choice_color" "$_no_color"

  while true; do
    printf "Your choice: "
    read -r _choice

    case $_choice in
    1)
      ln -s -f "$file" "$_symlink"
      printf "%sSuccess:%s %s updated.\n" "$_success_color" "$_no_color" "$_symlink"
      break
      ;;
    2)
      printf "\n%sSkipped:%s %s\n" "$_warning_color" "$_no_color" "$_file"
      break
      ;;
    *) printf "%sError:%s Enter %s[1]%s or %s[2]%s." "$_error_color" "$_no_color" "$_choice_color" "$_no_color" "$_choice_color" "$_no_color" ;;
    esac
  done
}

target_in_dotig_dir() {
  [ $# -ne 3 ] && error_callback

  local _file=$1
  local _symlink=$2
  local _symlink_target=$3
  local _choice

  if [ "$_symlink_target" = "$_file" ]; then
    printf "A symlink with the same target already exists.\n"
    printf "%sSkipped:%s %s\n" "$_warning_color" "$_no_color" "$file"
  else
    handle_update_target "$_file" "$_symlink" "$_symlink_target"
  fi
}

update_symlinks() {
  local _symlink
  local _symlink_target
  local _tmp

  printf "\nCreating symlink...\n"
  _tmp=$(mktemp "${TMPDIR:-/tmp}/dotig.XXXXXX")
  find_cmd > "$_tmp"

  while IFS= read -r file <&3; do
    if [ -h "$HOME${file#$DOTIG_PATH/home}" ]; then
      _symlink="$HOME${file#$DOTIG_PATH/home}"
      _symlink_target=$(readlink -f "$_symlink")
      case $_symlink_target in
        $DOTIG_PATH/*) target_in_dotig_dir "$file" "$_symlink" "$_symlink_target" ;;
        *) handle_update_target "$file" "$_symlink" "$_symlink_target" ;;
      esac
    elif [ -f "$HOME${file#$DOTIG_PATH/home}" ]; then
      printf "\n"
      handle_duplicate "$HOME${file#$DOTIG_PATH/home}" "$file"
    else
      ln -s "$file" "$HOME/${file#$DOTIG_PATH/home}"
      printf "%sSuccess:%s Symlink created for %s\n" "$_success_color" "$_no_color" "$file"
    fi
  done 3< "$_tmp"

  rm "$_tmp"

  printf "\n%sSuccess:%s Done. Symlinks have been updated except those that have possibly been manually skipped.\n" "$_success_color" "$_no_color"

  return_menu
}

replace_symlink_with_file() {
  [ $# -ne 2 ] && error_callback

  local _symlink=$1
  local _backup_file=$2

  cp --remove-destination "$_backup_file" "$_symlink"
  printf "%sSuccess:%s %s replaced with %s\n" "$_success_color" "$_no_color" "$_symlink" "$_backup_file"
}

handle_target_issue() {
  [ $# -ne 3 ] && error_callback

  local _symlink=$1
  local _target=$2
  local _backup_file=$3

  printf "\n%sWarning:%s The symlink target does not match with your backup file:\n" "$_warning_color" "$_no_color"
  printf "* Symlink: %s\n" "${_output_color}${_symlink}${_no_color}"
  printf "* Symlink target: %s\n" "${_output_color}${_target}${_no_color}"
  printf "* Backup file: %s\n" "${_output_color}${_backup_file}${_no_color}"

  printf "How do you want to proceed?\n"
  printf "%s[1]%s Replace symlink with backup file\n" "$_choice_color" "$_no_color"
  printf "%s[2]%s Skip this symlink\n" "$_choice_color" "$_no_color"

  while true; do
    printf "Your choice: "
    read -r _choice
    case $_choice in
    1)
      replace_symlink_with_file "$_symlink" "$_backup_file"
      break
      ;;
    2)
      printf "\n%sSkipped:%s %s\n" "$_warning_color" "$_no_color" "$_symlink"
      break
      ;;
    *) printf "%sError:%s Enter %s[1]%s or %s[2]%s." "$_error_color" "$_no_color" "$_choice_color" "$_no_color" "$_choice_color" "$_no_color" ;;
    esac
  done
}

remove_symlinks() {
  local _symlink_target
  local _expected_target
  local _tmp

  printf "\nReplacing symlinks with original files...\n"

  _tmp=$(mktemp "${TMPDIR:-/tmp}/dotig.XXXXXX")
  find "$HOME" -type l -not \( -path "$DOTIG_PATH/*" -prune \) -print > "$_tmp"

  while IFS= read -r symlink <&3; do
    _symlink_target=$(readlink "$symlink")
    case $_symlink_target in
      $DOTIG_PATH/*)
        _expected_target="${DOTIG_PATH}/home${symlink#$HOME}"
        if [ "$_expected_target" = "$_symlink_target" ]; then
          replace_symlink_with_file "$symlink" "$_expected_target"
        else
          handle_target_issue "$symlink" "$_symlink_target" "$_expected_target"
        fi
        ;;
      *) ;;
    esac
  done 3< "$_tmp"

  rm "$_tmp"

  printf "\n%sSuccess:%s Done. Symlinks have been replaced except those that have possibly been manually skipped.\n" "$_success_color" "$_no_color"

  return_menu
}

###############################################################################
# Git options
# Second feature of Dotig: handle commit, push and pull from the script.
###############################################################################

commit_changes() {
  local _staged_files

  git -C "$DOTIG_PATH" add --all
  _staged_files=$(get_staged_files_count) || true

  if [ "$_staged_files" -ne 0 ]; then
    printf "\n"
    git -C "$DOTIG_PATH" commit
    printf "%sSuccess:%s Changes committed!\n" "$_success_color" "$_no_color"
  else
    printf "\nCommit is not necessary, no staged files.\n"
  fi

  return_menu
}

push_changes() {
  local _unpushed_commits_count
  _unpushed_commits_count=$(get_unpushed_commits | wc -l)

  if [ "$_unpushed_commits_count" -ne 0 ]; then
    git -C "$DOTIG_PATH" push
    printf "\n%sSuccess:%s Commit(s) pushed!\n" "$_success_color" "$_no_color"
  else
    printf "\nNothing to push.\n"
  fi

  return_menu
}

pull_changes() {
  local _local_commit
  local _remote_commit
  local _common_ancestor

  update_remote_tracking

  _local_commit=$(get_local_commit) || true
  _remote_commit=$(get_remote_commit) || true
  _common_ancestor=$(get_common_ancestor "$_local_commit" "$_remote_commit") || true

  if ! is_repo_up_to_date "$_local_commit" "$_remote_commit" && is_pull_needed "$_local_commit" "$_common_ancestor"; then
    if ! is_repo_dirty; then
      git -C "$DOTIG_PATH" pull --rebase
      printf "\n%sSuccess:%s Repo is now up-to-date!\n" "$_success_color" "$_no_color"
    else
      printf "\n%sWarning:%s Dotig cannot pull. Your repo is dirty.\n" "$_warning_color" "$_no_color"
      printf "See the details below.\n"
      get_expanded_status
      printf "Commit or stash (manually) your changes if you want to pull.\n"
    fi
  else
    printf "\nNothing to pull.\n"
  fi

  return_menu
}

###############################################################################
# Menu
# Display all possible options.
###############################################################################

return_menu() {
  local _choice

  while true; do
    printf "\nWhat do you want to do: return to the menu %s[r]%s or exit %s[q]%s? " "$_choice_color" "$_no_color" "$_choice_color" "$_no_color"
    read -r _choice

    case $_choice in
    [rR]) return ;;
    [qQ]) exit ;;
    *)
      printf "%sError:%s invalid choice. Please enter %s[r]%seturn or %s[e]%sxit.\n" "$_error_color" "$_no_color" "$_choice_color" "$_no_color" "$_choice_color" "$_no_color"
      ;;
    esac
  done
}

print_menu_options() {
  printf "Choose an action to perform:\n"
  printf "%s[1]%s Add dotfile(s) to your repo\n" "$_choice_color" "$_no_color"
  printf "%s[2]%s Update symlinks\n" "$_choice_color" "$_no_color"
  printf "%s[3]%s Commit dotfiles changes\n" "$_choice_color" "$_no_color"
  printf "%s[4]%s Push changes to remote\n" "$_choice_color" "$_no_color"
  printf "%s[5]%s Pull changes from remote\n" "$_choice_color" "$_no_color"
  printf "%s[6]%s Remove all symlinks\n" "$_choice_color" "$_no_color"
  printf "%s[7]%s Check for Dotig update\n" "$_choice_color" "$_no_color"
  printf "%s[8]%s Print Dotig version\n" "$_choice_color" "$_no_color"
  printf "%s[q]%s Exit\n" "$_choice_color" "$_no_color"
}

print_menu() {
  local _choice

  while true; do
    print_menu_options
    printf "Your choice: "
    read -r _choice

    case $_choice in
    1) add_dotfiles ;;
    2) update_symlinks ;;
    3) commit_changes ;;
    4) push_changes ;;
    5) pull_changes ;;
    6) remove_symlinks ;;
    7) check_dotig_updates ;;
    8) print_version ;;
    [qQ]) exit ;;
    *) printf "\n%sError:%s Invalid choice. Try again.\n" "$_error_color" "$_no_color" ;;
    esac
  done
}

###############################################################################
# Main
# Entry point of Dotig.
###############################################################################

main() {
  display_logo
  check_requirements
  check_dotfiles_repo
  printf "\nWelcome!\n"
  get_repo_status
  print_menu
}

main "$@"
