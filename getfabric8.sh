#!/bin/bash

# Copyright 2014 The Kubernetes Authors All rights reserved.
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

# Download gofabric8
# Usage:
#   wget -q -O - https://get.fabric8.io | bash
# or
#   curl -sS https://get.fabric8.io | bash
# Set FABRIC8_SKIP_DOWNLOAD to non-empty to skip downloading release.
set -o errexit
set -o nounset
set -o pipefail

function get_latest_version_number {
  local -r latest_url="https://raw.githubusercontent.com/fabric8io/gofabric8/master/version/VERSION"
  if [[ $(which wget) ]]; then
    wget -qO- ${latest_url}
  elif [[ $(which curl) ]]; then
    curl -Ss ${latest_url}
  else
    echo "Couldn't find curl or wget.  Bailing out."
    exit 4
  fi
}

if [[ $(which gofabric8) ]]; then
  echo "gofabric8 already found on your PATH"
  exit 0
fi

fabric8_root=~/.fabric8/bin 
mkdir -p ${fabric8_root}

uname=$(uname)
if [[ "${uname}" == "Darwin" ]]; then
  platform="darwin"
elif [[ "${uname}" == "Linux" ]]; then
  platform="linux"
else
  echo "Unknown, unsupported platform: (${uname})."
  echo "Supported platforms: Linux, Darwin."
  echo "Bailing out."
  exit 2
fi

machine=$(uname -m)
if [[ "${machine}" == "x86_64" ]]; then
  arch="amd64"
elif [[ "${machine}" == "i686" ]]; then
  arch="386"
elif [[ "${machine}" == "arm*" ]]; then
  arch="arm"
else
  echo "Unknown, unsupported architecture (${machine})."
  echo "Supported architectures x86_64, i686, arm*"
  echo "Bailing out."
  exit 3
fi

release=`get_latest_version_number`
release_url=https://github.com/fabric8io/gofabric8/releases/download/v${release}/gofabric8-${platform}-${arch}

file=${fabric8_root}/gofabric8

echo "Downloading ${file} release ${release}"

if [[ "${FABRIC8_SKIP_DOWNLOAD-}" ]]; then
  echo "Skipping download"
  exit 0
fi 

tmpfile=$(mktemp /tmp/gofabric8-download.XXXXXX)
exec 3>"$tmpfile"
rm "$tmpfile"
  if [[ $(which wget) ]]; then
    wget -O ${tmpfile} ${release_url}
  elif [[ $(which curl) ]]; then
    curl -L -o ${tmpfile} ${release_url}
  else
    echo "Couldn't find curl or wget.  Bailing out."
    exit 1
  fi
  mv $tmpfile ${file}
echo foo >&3


chmod +x ${file}


echo "Installing binaries to ~/fabric8/bin"
echo
echo "Add '~/.fabric8/bin' to your path so you can execute the new binaries"
echo
echo "For example:"
echo "Edit your ~/.zshrc or ~/.bashrc  and append to the end of the file"
echo "export PATH=\$PATH:~/.fabric8/bin"
echo "source ~/.zshrc or ~/.zshrc"
echo 
echo "To work with the fabric8 microservices platform either:"
echo " - 'gofabric8 install' for a local cloud development platform" 
echo " - 'gofabric8 deploy' after connecting to an existing Kubernetes or OpenShift cluster"
