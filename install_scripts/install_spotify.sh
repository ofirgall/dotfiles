#!/bin/bash

set -e # Exit if fail

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

if $IS_REMOTE; then
    exit
fi

# Install jpochyla/psst
rm -rf /tmp/psst
mkdir /tmp/psst
cd /tmp/psst
wget https://nightly.link/jpochyla/psst/workflows/build/master/psst-deb.zip

unzip psst-deb.zip

# libssl1.1
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb

sudo dpkg -i *.deb
