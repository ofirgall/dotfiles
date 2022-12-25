#!/bin/bash

set -e # Exit if fail

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

if $IS_REMOTE; then
    exit
fi


curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/spotify.gpg
echo "deb [signed-by=/usr/share/keyrings/spotify.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt update
sudo apt install -y spotify-client

# Install jpochyla/psst
rm -rf /tmp/psst
mkdir /tmp/psst
cd /tmp/psst
wget https://nightly.link/jpochyla/psst/workflows/build/master/psst-deb.zip

unzip psst-deb.zip

# libssl1.1
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb

sudo dpkg -i *.deb

# Spicetify
curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.sh | sh
curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.sh | sh
