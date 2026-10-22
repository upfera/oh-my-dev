#!/bin/bash

curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

sudo apt-get update
sudo ACCEPT_EULA=Y apt-get -y install mssql-tools18 unixodbc-dev

echo "export PATH=\$PATH:/opt/mssql-tools18/bin" >> ~/.bashrc
echo "export PATH=\$PATH:/opt/mssql-tools18/bin" >> ~/.zshrc