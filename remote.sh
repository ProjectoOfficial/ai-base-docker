#!/bin/bash

################################################################################
# Script filename: remote.sh
# 
# Description: creates a ssh connection to a remote host and creates a docker context to run docker on the remote host
#
# Author: Daniel Rossi
# Date: 24/05/24
# Version: 1.0
#
# Notes: takes as input: email, remote host username, remote host address, remote host password
#
# Dependencies: 
#   - Docker installed on the remote host and on the local machine
#   - ssh-keygen
#   - ssh server running on the remote host
#
################################################################################
set -e

echo "Configure your remote connection to the host running the docker"
echo "Please run the docker on the remote host to be able to detect it at the end of the procedure"
CURRENT_PATH=$(pwd)

files=("remote_key" "remote_key.pub")

echo ""
echo "Removing previous configuration..."
for file in "${files[@]}"; do
    if [ -e "$file" ]; then
        echo "Removing $file..."
        rm "$file"
    fi
done

echo ""
read -p "Please provide your email: " email
remote_key="$CURRENT_PATH/remote_key"
ssh-keygen -t rsa -b 4096 -C "$email" -f "$remote_key" -N ""

echo ""
echo "Updating remote host ssh authorised keys..."
read -p "Please provide remote host username: " remote_user
read -p "Please provide remote host address: " remote_host

local_public_key_file="$CURRENT_PATH/remote_key.pub"
cat "$local_public_key_file" | ssh "$remote_user@$remote_host" 'cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'

echo ""
echo "Updating local ssh config"
config_file=~/.ssh/config
if grep -q "^Host remotedocker$" "$config_file"; then
    # Se esiste, aggiorna i parametri di configurazione
    sed -i.bak "/^Host remotedocker$/,/^$/ {
        s/^\(\s*HostName\s*\).*$/\1$remote_host/;
        s/^\(\s*User\s*\).*$/\1$remote_user/;
        s,^\(\s*IdentityFile\s*\).*,\1$remote_key,
    }" "$config_file"
    echo "Configurazione per remotedocker aggiornata."
else
    # Se non esiste, aggiungi una nuova configurazione
    echo "Host remotedocker
    HostName $remote_host
    User $remote_user
    IdentityFile $remote_key" >> ~/.ssh/config
    echo "Configurazione per remotedocker aggiunta."
fi

chmod 600 "$remote_key"
chmod 644 "$local_public_key_file"
chmod 600 ~/.ssh/config


echo ""
echo "Creating docker context remote..."
docker context use default
docker context rm remote -f
docker context create remote --docker "host=ssh://remotedocker"
docker context use remote
docker --context remote ps

