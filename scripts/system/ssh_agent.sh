#!/bin/bash

# Check if ssh-agent is installed
if ! command -v ssh-agent &>/dev/null; then
    echo "ssh-agent is not installed. Installing..."
    sudo apt update
    sudo apt install openssh-client -y
else
    echo "ssh-agent is already installed."
fi

# Detect the shell (Bash or Zsh)
SHELL_NAME=$(basename "$SHELL")

# Determine the correct file to modify
if [ "$SHELL_NAME" == "bash" ]; then
    CONFIG_FILE="$HOME/.bashrc"
elif [ "$SHELL_NAME" == "zsh" ]; then
    CONFIG_FILE="$HOME/.zshrc"
else
    echo "Unsupported shell: $SHELL_NAME. This script only supports Bash and Zsh."
    exit 1
fi

# Prepare the configuration text to add to the file
CONFIG_TEXT=$(cat <<EOF

# Start ssh-agent if not running and add all private keys
if [ -z "\$SSH_AUTH_SOCK" ] && [ -x "\$(command -v ssh-agent)" ]; then
    eval "\$(ssh-agent -s)"
    for possiblekey in ~/.ssh/id_*; do
        if grep -q PRIVATE "\$possiblekey"; then
            echo "\$possiblekey"
            ssh-add "\$possiblekey"
        fi
    done
fi
EOF
)

# Check if the ssh-agent setup is already in the config file
if ! grep -q "ssh-agent" "$CONFIG_FILE"; then
    echo "Adding ssh-agent startup to $CONFIG_FILE"
    echo "$CONFIG_TEXT" >> "$CONFIG_FILE"
    echo "ssh-agent setup added to $CONFIG_FILE."
else
    echo "ssh-agent setup is already configured in $CONFIG_FILE."
fi

# Apply changes immediately
source "$CONFIG_FILE"

# Inform the user
echo "Setup complete. SSH agent will now start automatically and add all private keys in ~/.ssh."
