#!/bin/bash

sudo mkdir -p /etc/ansible

sudo tee /etc/ansible/ansible.cfg > /dev/null <<EOF
[defaults]
callbacks_enabled = profile_tasks
deprecation_warnings = False
EOF