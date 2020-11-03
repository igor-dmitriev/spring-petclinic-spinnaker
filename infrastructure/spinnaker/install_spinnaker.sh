#!/bin/sh

echo "Start installing Spinnaker"

# Spinnaker version
sudo hal config version edit --version ${spinnaker_version}

# Install Spinnaker environment variables
sudo tee /etc/default/spinnaker >/dev/null <<EOF
SPINNAKER_PUBLIC_IP=${spinnaker_ip}
SPINNAKER_DB_HOST=${spinnaker_db_host}
SPINNAKER_DB_PASSWORD=${spinnaker_db_password}
SPINNAKER_AUTH_LOGIN=${spinnaker_auth_login}
SPINNAKER_AUTH_PASSWORD=${spinnaker_auth_password}
EOF

sudo hal deploy apply

# Start on OS system boot
sudo systemctl enable apache2
sudo systemctl enable gate
sudo systemctl enable orca
sudo systemctl enable igor
sudo systemctl enable front50
sudo systemctl enable echo
sudo systemctl enable clouddriver
sudo systemctl enable rosco

echo "Finish installing Spinnaker"