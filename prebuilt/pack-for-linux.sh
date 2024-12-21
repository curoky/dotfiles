#!/usr/bin/env bash
set -xeuo pipefail

source ./common.sh

# task --list-all | sed -e 's/://g' -e 's/*//g'
pkgs=(
  aria2
  atuin
  autoconf
  automake
  bash
  bat
  bazelisk
  binutils
  bison
  bzip2
  cacert
  connect
  coreutils
  croc
  curl
  diffutils
  ethtool
  eza
  fd
  file
  findutils
  flex
  fzf
  gdb
  gdu
  gettext
  gh
  git
  git-absorb
  git-extras
  git-lfs
  glibcLocales
  gnugrep
  gnumake
  gnupatch
  gnupg-minimal
  gnused
  gnutar
  go-task
  gost
  gzip
  inetutils
  iproute2
  iptables
  iputils
  jq
  krb5
  less
  libcap
  libtool
  llvmPackages_18.clang-unwrapped
  lsb-release
  lsof
  m4
  man
  miniserve
  ncdu_1
  netcat
  nettools
  ninja
  nixfmt-rfc-style
  nixpkgs-fmt
  numactl
  openssh_gssapi
  openssl
  patchelf
  perl
  pkg-config
  procps
  procs
  protobuf_24
  protobuf_25
  protobuf_28
  protobuf_3_8_0
  protobuf_3_9_2
  python311
  rime-bundle
  rsync
  ruff
  #  setup
  #  setup-extra
  shfmt
  silver-searcher
  snappy
  starship
  strace
  tmux
  tmux-bundle
  tree
  tzdata
  unzip
  util-linux
  vim
  vim-bundle
  wget
  xxd
  xz
  zip
  zlib
  zlib-ng
  zsh
  zsh-bundle
  zstd
)
rm -rf tmp

for pkg in "${pkgs[@]}"; do
  download_pkg ${pkg} &
done
wait

mkdir tmp/prebuilt/bin/
mkdir -p tmp/prebuilt/pkgs/clang-format-18/bin
cp tmp/prebuilt/pkgs/llvmPackages_18.clang-unwrapped/bin/clang-format tmp/prebuilt/pkgs/clang-format-18/bin/clang-format
rm -rf tmp/prebuilt/pkgs/llvmPackages_18.clang-unwrapped

rm -rf tmp/prebuilt/pkgs/glibcLocales

rename_wrapped
remove_unneeded
strip_bin
link_bin
copy_wrapper

ln -s -r tmp/prebuilt/bin/bazelisk tmp/prebuilt/bin/bazel
ln -s -r tmp/prebuilt/bin/vim tmp/prebuilt/bin/vi
ln -s -r tmp/prebuilt/bin/clang-format tmp/prebuilt/bin/clang-format-18

./setup-pipx.sh
tar -czvf tmp/prebuilt.linux_amd64.tar.gz tmp/prebuilt
