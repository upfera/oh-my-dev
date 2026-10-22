#!/bin/bash

mkdir -p ~/.zsh/plugins/kubectl-completions
kubectl completion zsh > ~/.zsh/plugins/kubectl-completions/kubectl-completions.zsh
echo -e '\nsource ~/.zsh/plugins/kubectl-completions/kubectl-completions.zsh' >> ~/.zshrc
