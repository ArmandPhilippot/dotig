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
