#!/bin/bash
#
# Sdotit
# A dotfiles manager to quickly setup your machine & synchronize your dotfiles.
#
# Requirements: Git and GNU Stow.
# Author: Armand Philippot <https://www.armandphilippot.com/>
# URL: https://github.com/ArmandPhilippot/sdotit

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

SDOTIT_VERSION="0.1.0"
SDOTIT_LOGO=$(
  cat <<-EOF
################################################################
##                 _____                                      ##
##                / ____|    _       _   _ _                  ##
##               | (___   __| | ___ | |_(_) |_                ##
##                \___ \ / _  |/ _ \| __| | __|               ##
##                ____) | (_| | (_) | |_| | |_                ##
##               |_____/ \__,_|\___/ \__|_|\__|               ##
##                                                            ##
################################################################
EOF
)
SDOTIT_PATH=""


_error_color=$'\e[31m'
_success_color=$'\e[32m'
_warning_color=$'\e[33m'
_choice_color=$'\e[34m'
_output_color=$'\e[35m'
_no_color=$'\e[0m'

###############################################################################
# Helpers
###############################################################################

display_logo() {
  echo -e "${SDOTIT_LOGO}\n"
}

error_callback() {
  echo -e "${_error_color}An unexpected error occurred.${_no_color} Exit."
  exit 1
}

set_path() {
  local _path
  read -r -p "Set the path: " _path

  while [ ! -d "$_path" ]; do
    read -r -p "${_error_color}Error:${_no_color} It is not a directory. Please enter a valid path: " _path
  done

  eval "$1=$_path"
}

is_correct_path() {
  [ $# -ne 1 ] && error_callback

  local _validation
  local _valid_path
  local -n _path=$1

  while read -r -p "Is ${_output_color}${_path}${_no_color} correct? ${_choice_color}[y/n]${_no_color} " _validation; do
    case $_validation in
    [yY])
      break
      ;;
    [nN])
      set_path _valid_path
      _path=$_valid_path
      ;;
    *) echo "${_error_color}Error:${_no_color} please enter ${_choice_color}[y]${_no_color}es or ${_choice_color}[n]${_no_color}o." ;;
    esac
  done
}

###############################################################################
# Safety Checks
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
  echo "Identifying the operating system..."

  if is_linux; then
    echo -e "${_success_color}Success:${_no_color} Linux is supported."
  else
    echo -e "${_error_color}Error:${_no_color} Linux is the only supported operating system."
    echo "Exit."
    exit 1
  fi

  if ! is_manjaro; then
    echo -e "${_warning_color}Warning:${_no_color} Sdotit has only been tested with Manjaro."
  fi
}

is_git_installed() {
  [ -x "$(command -v git)" ]
}

is_stow_installed() {
  [ -x "$(command -v stow)" ]
}

check_commands() {
  echo -e "\nChecking installed programs..."

  if is_git_installed; then
    echo -e "${_success_color}Success:${_no_color} Git is installed."
  else
    echo -e "${_error_color}Error:${_no_color} Sdotit needs Git to function properly."
    echo -e "Please install it before using this program.\n"
    echo "Exit."
    exit 1
  fi

  if is_stow_installed; then
    echo -e "${_success_color}Success:${_no_color} Stow is installed."
  else
    echo -e "${_error_color}Error:${_no_color} Sdotit needs GNU Stow to function properly."
    echo -e "Please install it before using this program.\n"
    echo "Exit."
    exit 1
  fi
}

check_requirements() {
  echo "Checking requirements..."
  check_os
  check_commands
  echo -e "${_success_color}Success:${_no_color} Requirements checked!"
  echo -e "Let's continue.\n"
}

###############################################################################
# Repo configuration
###############################################################################

set_dotfiles_dir() {
  local _path

  set_path _path
  is_correct_path _path

  eval "$1=$_path"
}

is_dotfiles_dir_set() {
  local _dotfiles_path

  echo -e "For conveniance, Sdotit uses a \$DOTFILES variable to determine the dotfiles backup path. If it is not set, you may want to declare it for future use.\n"
  echo "Checking if a \$DOTFILES variable is set..."

  if [ ! "$DOTFILES" ]; then
    echo "${_warning_color}Warning:${_no_color} The \$DOTFILES variable is not set."
    set_dotfiles_dir _dotfiles_path
  elif [ ! -d "$DOTFILES" ]; then
    echo "${_warning_color}Warning:${_no_color} The \$DOTFILES variable does not seem to match a directory."
    set_dotfiles_dir _dotfiles_path
  else
    echo "${_success_color}Success:${_no_color} Found \$DOTFILES variable."
    _dotfiles_path=$DOTFILES
    is_correct_path _dotfiles_path
  fi

  eval "$1=$_dotfiles_path"
}

get_current_branch() {
  git -C "${SDOTIT_PATH}" symbolic-ref --quiet --short HEAD
}

get_branch_upstream() {
  local _git_branch
  _git_branch=$(get_current_branch)
  git -C "${SDOTIT_PATH}" config branch."${_git_branch}".remote &> /dev/null
}

get_existing_remotes() {
  git -C "${SDOTIT_PATH}" remote
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

  echo -e "${_warning_color}Warning:${_no_color} Your repo contains multiple remotes:"
  echo "$_git_remotes"
  read -r -p "Choose the remote to use for ${_output_color}${_branch_name}${_no_color}: " _choice

  while ! is_valid_remote_name "$_choice" "$_git_remotes"; do
    echo -e "\n${_error_color}Error:${_no_color} Remote name invalid."
    echo "Use one of:"
    echo -e "${_choice_color}${_git_remotes}${_no_color}"
    read -r -p "Enter a valid remote name: " _choice
  done
  echo

  eval "$1=$_choice"
}

set_branch_upstream() {
  local _git_branch
  local _git_remotes
  local _remote_name

  _git_branch=$(get_current_branch)
  _git_remotes=$(get_existing_remotes)

  if [ "$(echo "$_git_remotes" | wc -l)" -gt 1 ]; then
    ask_remote_name _remote_name
  else
    _remote_name=$_git_remotes
  fi

  git -C "${SDOTIT_PATH}" config branch."${_git_branch}".remote "$_remote_name"
  echo "${_success_color}Success:${_no_color} Upstream set."
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

  echo -e "\nChecking if this URL exist. Your SSH passphrase can be requested."

  if ! git ls-remote "$_valid_remote" &> /dev/null; then
    while ! git ls-remote "$_valid_remote" &> /dev/null; do
      echo "${_error_color}Error:${_no_color} This remote URL does not exist."
      read -r -p "Enter a valid remote URL: " _valid_remote
    done
  fi
}

set_remote() {
  local _remote

  echo -e "Sdotit needs to know your remote to perform some actions (status, push, pull)."
  read -r -p "Please enter your remote address: " _remote

  while ! is_valid_remote_url "$_remote"; do
    echo -e "\n${_error_color}Error:${_no_color} The remote URL is not valid. URL must starts with 'https' or 'git@'."
    read -r -p "Please enter a valid remote address: " _remote
  done

  is_remote_exists _remote
  git -C "${SDOTIT_PATH}" remote add origin "$_remote"
  echo "${_success_color}Success:${_no_color} Remote set."
}

is_remote_set() {
  if ! git -C "${SDOTIT_PATH}" config --get-regexp '^remote\.' &> /dev/null; then
    echo -e "\nSdotit is a Git repository but the remote is not set."
    set_remote
  fi
}

init_git() {
  git -C "$SDOTIT_PATH" init
  echo
  set_remote
  set_branch_upstream
}

is_git_repo() {
  git -C "$SDOTIT_PATH" rev-parse --git-dir &> /dev/null
}

is_git_configured() {
  local _choice

  echo -e "\nChecking if Git is configured..."

  if ! is_git_repo; then
    echo -e "\n${_warning_color}Warning:${_no_color} Your dotfiles directory is not a Git repository."
    while read -r -p "Do you want to configure it? ${_choice_color}[y/n]${_no_color} " _choice; do
      case $_choice in
        [yY])
          init_git
          return 0
          ;;
        [nN])
          echo -e "\n${_warning_color}Warning:${_no_color} Sdotit needs a Git repository to properly function. Please configure it manually before using this program."
          echo "Exit."
          exit
          ;;
        *) echo -e "${_error_color}Error:${_no_color} Enter ${_choice_color}[y]${_no_color}es or ${_choice_color}[n]${_no_color}no" ;;
      esac
    done
  else
    is_remote_set
    is_upstream_set
  fi
}

check_dotfiles_repo() {
  is_dotfiles_dir_set SDOTIT_PATH
  is_git_configured
  echo -e "${_success_color}Success:${_no_color} Your dotfiles repo is ready."
}

###############################################################################
# Repo Status
###############################################################################

get_repo_status() {
  local _local_commit
  local _remote_commit
  local _common_ancestor

  echo -e "\nChecking status..."
  echo "Your SSH passphrase can be requested."
  git -C "$SDOTIT_PATH" fetch

  _local_commit=$(git -C "$SDOTIT_PATH" rev-parse HEAD)
  _remote_commit=$(git -C "$SDOTIT_PATH" rev-parse FETCH_HEAD)
  _common_ancestor=$(git -C "$SDOTIT_PATH" merge-base HEAD "$_remote_commit")

  if [ "$_local_commit" = "$_remote_commit" ]; then
    echo -e "Status: ${_success_color}up-to-date!${_no_color}\n"
  else
    [ "$_local_commit" = "$_common_ancestor" ] && echo -e "Status: ${_warning_color}pull needed!${_no_color}\n"
    [ "$_remote_commit" = "$_common_ancestor" ] && echo -e "Status: ${_warning_color}push needed!${_no_color}\n"
  fi
}

###############################################################################
# Sdotit options
###############################################################################

print_version() {
  echo -e "\nYour Sdotit version is: $SDOTIT_VERSION\n"
  return_menu
}

get_latest_release() {
  curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/ArmandPhilippot/sdotit/releases/latest
}

check_sdotit_updates() {
  local _latest_release
  local _tag_name
  local _new_version
  local _download_zip
  local _download_link
  local _not_found

  _latest_release=$(get_latest_release)
  _not_found=$(echo "$_latest_release" | { grep -Po '"message": "Not Found"' || true; })

  if [ "$_not_found" ] ; then
    echo -e "\n${_error_color}Error:${_no_color} could not find any release..."
  else
    _tag_name=$(echo "$_latest_release" | grep -Po '"tag_name":.*?[^\\]",')
    _new_version=$(echo "$_tag_name" | grep -Po '(?=v).*(?=",)' | sed 's/^v//')

    if [ "$_new_version" = "$SDOTIT_VERSION" ]; then
      echo -e "\n${_success_color}Success:${_no_color} Your Sdotit version is up to date!\n"
    else
      _download_zip=$(echo "$_latest_release" | grep -Po '"zipball_url":.*?[^\\]",')
      _download_link=$(echo "$_download_zip" | grep -Po 'http.*(?=",)')

      echo -e "\n${_warning_color}Warning:${_no_color} Your Sdotit version is outdated!"
      echo -e "A new version is available: ${_new_version}\n"
      echo -e "You can download it here: ${_download_link}\n"
    fi
  fi

  return_menu
}

###############################################################################
# Symlinking options
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
  if diff -q "$1" "$2" &> /dev/null; then
    echo "Both files are identical".
  else
    echo "The two files are different. See the diff:"
    diff --color -u "$1" "$2" || [ $? -eq 1 ]
  fi
}

handle_duplicate() {
  local _choice
  local _home_dotfile=$1
  local _backup_dotfile=$2

  echo "${_warning_color}Warning:${_no_color} A file with the same name already exists."

  [ -h "$_backup_dotfile" ] && echo "${_warning_color}Warning:${_no_color} ${_output_color}${_backup_dotfile}${_no_color} is a symlink."
  [ -h "$_home_dotfile" ] && echo "${_warning_color}Warning:${_no_color} ${_output_color}${_home_dotfile}${_no_color} is a symlink."

  echo "How do you want to proceed?"
  echo "${_choice_color}[1]${_no_color} Show diff"
  echo "${_choice_color}[2]${_no_color} Use ${_output_color}${_home_dotfile}${_no_color} (delete the other)"
  echo "${_choice_color}[3]${_no_color} Use ${_output_color}${_backup_dotfile}${_no_color} (delete the other)"
  echo "${_choice_color}[4]${_no_color} Skip this file"

  while read -r -p "Your choice: " _choice; do
    case $_choice in
      1) print_diff "$_home_dotfile" "$_backup_dotfile" ;;
      2)
        echo "Deleting ${_output_color}${_backup_dotfile}${_no_color} and creating symlink..."
        mv -f "$_home_dotfile" "$_backup_dotfile"
        ln -s "$_backup_dotfile" "$_home_dotfile"
        echo -e "Done.\n"
        break
        ;;
      3)
        echo "Deleting ${_output_color}${_home_dotfile}${_no_color} and creating symlink..."
        rm "$_home_dotfile"
        ln -s "$_backup_dotfile" "$_home_dotfile"
        echo -e "Done.\n"
        break
        ;;
      4)
        echo -e "${_warning_color}Skipped:${_no_color} ${_home_dotfile}\n"
        break
        ;;
      *) echo "${_error_color}Error:${_no_color} choose between ${_choice_color}[1]${_no_color}, ${_choice_color}[2]${_no_color}, ${_choice_color}[3]${_no_color} or ${_choice_color}[4]${_no_color}."
    esac
  done
}

add_dotfiles() {
  local _dotfiles
  local _dest

  echo
  read -r -e -p "Enter the dotfiles names: " -a _dotfiles

  for _dotfile in "${_dotfiles[@]}"; do
    get_absolute_path _dotfile
    _dest="$SDOTIT_PATH/home${_dotfile#$HOME}"
    if [ -f "$_dest" ]; then
      handle_duplicate "$_dotfile" "$_dest"
    else
      mkdir -p "$(dirname "$_dest")"
      mv "$_dotfile" "$_dest"
      ln -s "$_dest" "$_dotfile"
      echo -e "${_success_color}Success:${_no_color} $_dotfile moved and symlink created.\n"
    fi
  done

  return_menu
}

###############################################################################
# Menu
###############################################################################

return_menu() {
  local _choice
  while true; do
    read -r -p "What do you want to do: return to the menu ${_choice_color}[r]${_no_color} or exit ${_choice_color}[q]${_no_color}? " _choice

    case $_choice in
    [rR]) return ;;
    [qQ]) exit ;;
    *)
      echo -e "${_error_color}Error:${_no_color} invalid choice."
      echo "Please enter ${_choice_color}[r]${_no_color}eturn or ${_choice_color}[e]${_no_color}xit: "
      ;;
    esac
  done
}

print_menu_options() {
  echo "Choose an action to perform:"
  echo "${_choice_color}[1]${_no_color} Add dotfile(s) to your repo"
  echo "${_choice_color}[2]${_no_color} Update symlinks"
  echo "${_choice_color}[3]${_no_color} Commit dotfiles changes"
  echo "${_choice_color}[4]${_no_color} Push changes to remote"
  echo "${_choice_color}[5]${_no_color} Pull changes from remote"
  echo "${_choice_color}[6]${_no_color} Remove all symlinks"
  echo "${_choice_color}[7]${_no_color} Check for Sdotit update"
  echo "${_choice_color}[8]${_no_color} Print Sdotit version"
  echo "${_choice_color}[q]${_no_color} Exit"
}

print_menu() {
  local _choice

  while true; do
    print_menu_options
    read -r -p "Your choice: " _choice

    case $_choice in
    1) add_dotfiles ;;
    2) ;;
    3) ;;
    4) ;;
    5) ;;
    6) ;;
    7) check_sdotit_updates ;;
    8) print_version ;;
    [qQ]) exit ;;
    *) echo -e "\n${_error_color}Error:${_no_color} Invalid choice. Try again." ;;
    esac
  done
}

###############################################################################
# Main
###############################################################################

main() {
  display_logo
  check_requirements
  check_dotfiles_repo
  echo -e "\nWelcome!"
  get_repo_status
  print_menu
}

main "$@"
