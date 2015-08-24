#!/bin/bash
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
#

set -ex

mkdir /scratch
cd /scratch

tar --strip-components 1 -C . -xf /src.tar.gz

cp -R /specs/debian .

dch \
  -b \
  -v $(cat .auroraversion)~SNAPSHOT \
  -u low --maintmaint \
  "Apache Aurora package builder <dev@aurora.apache.org> $(date -R)"

dpkg-buildpackage -uc -b -tc

mv ../*.deb /dist
