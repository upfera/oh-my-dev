mkdir -p ~/.zsh/plugins/chezmoi-completions
chezmoi completion zsh --output=~/.zsh/plugins/chezmoi-completions/chezmoi.zsh

echo -e '\nsource ~/.zsh/plugins/chezmoi-completions/chezmoi.zsh' >> ~/.zshrc