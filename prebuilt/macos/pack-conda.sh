#!/usr/bin/env bash
set -xeuo pipefail

export PATH=$PATH:/sbin

sudo rm -rf /opt/conda
sudo mkdir /opt/conda
sudo chown "$(id -u):$(id -g)" /opt/conda

rm -rf tmp
mkdir -p tmp
curl -sSL -o tmp/miniconda.sh \
  https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh

sed -i -e 's/| md5/| openssl md5/g' tmp/miniconda.sh
bash tmp/miniconda.sh -b -u -p /opt/conda

/workspace/dotbox/docker/stage/conda/setup-conda-env.sh -e ../../host/mac/conf/conda/py3.yaml

tar -c --gunzip -f tmp/conda.darwin-arm64.tar.gz /opt/conda
