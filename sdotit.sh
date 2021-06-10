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
# Main
###############################################################################

main() {
  display_logo
  check_requirements
}

main "$@"
