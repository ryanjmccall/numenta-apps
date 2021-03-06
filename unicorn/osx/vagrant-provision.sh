#!/bin/bash
# ----------------------------------------------------------------------
# Numenta Platform for Intelligent Computing (NuPIC)
# Copyright (C) 2016, Numenta, Inc.  Unless you have purchased from
# Numenta, Inc. a separate commercial license for this software code, the
# following terms and conditions apply:
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Affero Public License for more details.
#
# You should have received a copy of the GNU Affero Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# http://numenta.org/licenses/
# ----------------------------------------------------------------------

# Script used to provision additional requirements not satisfied by image alone.
# Arguments:
#   1) node version (i.e. "5.10.0")

set -o verbose
set -o xtrace

# Update brew
rm /usr/local/share/man/man1/brew-cask.1
sudo -u vagrant -i brew tap --repair
sudo -u vagrant -i brew update

# Initialize .bashrc with PATH
sudo -u vagrant /usr/libexec/path_helper -s >> /Users/vagrant/.bashrc
sudo -u vagrant ln -s .bashrc .bash_profile

# Install cmake with homebrew
sudo -u vagrant -i brew install cmake

# Install NVM
sudo -u vagrant -i brew uninstall node
sudo -u vagrant -i brew install nvm
sudo -u vagrant mkdir /Users/vagrant/.nvm
sudo -u vagrant echo "export NVM_DIR=/Users/vagrant/.nvm" >> /Users/vagrant/.bashrc
sudo -u vagrant echo "source $(brew --prefix nvm)/nvm.sh" >> /Users/vagrant/.bashrc

# Switch nodejs to version specified in 'Vagrant' file
sudo -u vagrant -i nvm install v$1
