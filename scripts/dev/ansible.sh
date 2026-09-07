#!/bin/bash

sudo apt -y install ansible

sudo bash -c 'printf "[defaults]\ncallbacks_enabled = profile_tasks\ndeprecation_warnings = False\n" > /etc/ansible/ansible.cfg'