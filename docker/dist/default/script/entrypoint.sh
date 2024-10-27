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

echo "SSHD_PORT: $SSHD_PORT"
echo "PROFILE_PASS: $PROFILE_PASS"

/app/dotbox/docker/dist/default/script/link-path.sh
/app/dotbox/docker/base/script/setup-userconf.sh
sudo -u x /app/dotbox/docker/base/script/setup-userconf.sh
/app/dotbox/docker/dist/default/script/start-sshd.sh $SSHD_PORT

sudo -u x bash /app/dotbox/docker/dist/default/script/setup-profile.sh $PROFILE_PASS &

sudo -u x bash -c 'cd /app/dotbox && pre-commit install-hooks' &

while true; do sleep 86400; done
# exec /lib/systemd/systemd
