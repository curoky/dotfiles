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

set -euo pipefail

OPTIONS=$(getopt -o c:e:t:v:n: --long conda_root:,env_file:,add_tf_env,cuda_version:,cudnn_version: -- "$@")

if [ $? -ne 0 ]; then
  echo "Usage: $0 [-c conda_root] [-t] [-v cuda_version] [-n cudnn_version]" 1>&2
  exit 1
fi

eval set -- "$OPTIONS"

env_file=""
conda_root="/app/conda"
add_tf_env=false
cuda_version=""
cudnn_version=""

while true; do
  case "$1" in
    -c | --conda_root)
      conda_root="$2"
      shift 2
      ;;
    -e | --env_file)
      env_file="$2"
      shift 2
      ;;
    -t | --add_tf_env)
      add_tf_env=true
      shift
      ;;
    -v | --cuda_version)
      cuda_version="$2"
      shift 2
      ;;
    -n | --cudnn_version)
      cudnn_version="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Invalid option: $1" 1>&2
      exit 1
      ;;
  esac
done

echo "conda_root: $conda_root"
echo "env_file: $env_file"
echo "add_tf_env: $add_tf_env"
echo "cuda_version: $cuda_version"
echo "cudnn_version: $cudnn_version"

env_name=$(grep -oP "name: \K\S+" $env_file)
python_version=$(grep -oP " python=\K\S+" $env_file)
# python_short_version=$(conda run -n $env_name python --version 2>&1 | awk '{print $2}' | cut -d '.' -f1,2)
python_short_version=$(grep -oP " python=\K\S+" $env_file | cut -d '.' -f1,2)

echo "create $env_name($env_file) on $conda_root with python_version=$python_version, python_short_version=$python_short_version"

export CONDA_ROOT=$conda_root
export PATH=$CONDA_ROOT/bin:$PATH
export PIP_CACHE_DIR=/tmp/pip
export PKG_CONFIG_PATH=$CONDA_ROOT/envs/$env_name/lib/pkgconfig
export CFLAGS="-I$CONDA_ROOT/envs/$env_name/include"
export LDFLAGS="-I$CONDA_ROOT/envs/$env_name/lib"

conda env remove -n $env_name -y || echo not exist
conda create -n $env_name python=$python_version -y --no-default-packages
rm -rf $CONDA_ROOT/envs/$env_name/compiler_compat/
conda env update -f ${env_file}

if [[ $add_tf_env == "true" ]]; then
  cuda_short_version=${cuda_version%%.*}
  echo "add tf env with cuda_version=${cuda_version}, cudnn_version=${cudnn_version}, cuda_short_version=${cuda_short_version}"
  mkdir -p $CONDA_ROOT/envs/$env_name/etc/conda/activate.d
  target_env_file=$CONDA_ROOT/envs/$env_name/etc/conda/activate.d/env_vars.sh
  echo '' >$target_env_file

  echo "export LD_LIBRARY_PATH=/usr/local/cuda-${cuda_version}/lib64:/usr/local/cuda-${cuda_version}/extras/CUPTI/lib64/:\$LD_LIBRARY_PATH" >>$target_env_file
  echo "export LD_LIBRARY_PATH=/app/nvidia/cudnn${cudnn_version}-cu${cuda_short_version}/lib64:\$LD_LIBRARY_PATH" >>$target_env_file
  echo "export CUDNN_INSTALL_PATH=/app/nvidia/cudnn${cudnn_version}-cu${cuda_short_version}" >>$target_env_file
fi

conda clean -y -a
