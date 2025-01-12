#!/usr/bin/env bash
# Copyright (c) 2018-2024 curoky(cccuroky@gmail.com).
#
# This file is part of dotbox.
# See https://github.com/curoky/dotbox for further info.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -xeuo pipefail

source ../common/utils.sh

# task --list-all | sed -e 's/://g' -e 's/*//g'
pkgs=(
  aria2
  bzip2
  connect
  coreutils
  findutils
  fzf
  gawk
  getopt
  gettext
  git-lfs
  gnugrep
  gnupatch
  gnupatch
  gnused
  gnutar
  go-task
  gost
  gdu
  inetutils
  lsof
  m4
  ncdu_1
  netcat
  openssl
  rime-bundle
  rsync
  shfmt
  silver-searcher
  unzip
  vim
  vim-bundle
  xz
  zip
  zsh
  zsh-bundle
  zstd
  eza
  bat
  atuin
  fd
  git-absorb
  starship
  git-extras
  # ruff need link jemalloc
)
rm -rf tmp
mkdir -p tmp

curl https://raw.githubusercontent.com/curoky/prebuilt-tools/refs/heads/master/tools/install.sh >tmp/install.sh
for pkg in "${pkgs[@]}"; do
  bash tmp/install.sh -n $pkg -d tmp/download -i tmp/prebuilt/pkgs/$pkg -a darwin_arm64 &
done
wait

touch tmp/prebuilt/pkgs/vim/skip_link
touch tmp/prebuilt/pkgs/zsh/skip_link
remove_unneeded

rename_wrapped
link_to_bin
link_zsh_comp
add_dotbox

cd tmp
tar -c --gunzip -f prebuilt.darwin_arm64.tar.gz prebuilt
