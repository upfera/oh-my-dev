#!/bin/bash

mkdir -p ~/.zsh/plugins

# Start git clones in parallel
[[ -d ~/.zsh/plugins/fast-syntax-highlighting/.git ]] || git clone https://github.com/zdharma-zmirror/fast-syntax-highlighting.git ~/.zsh/plugins/fast-syntax-highlighting &
pid1=$!

[[ -d ~/.zsh/plugins/zsh-autosuggestions/.git ]] || git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/plugins/zsh-autosuggestions &
pid2=$!

[[ -d ~/.zsh/plugins/zsh-completions/.git ]] || git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/plugins/zsh-completions &
pid3=$!

# Wait for all clones to finish (slow part)
wait $pid1 $pid2 $pid3

# Then do echo commands sequentially (fast part)
grep -qxF 'source ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh' ~/.zshrc || echo 'source ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh' >> ~/.zshrc
grep -qxF 'source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' ~/.zshrc || echo 'source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc

echo 'skip_global_compinit=1' > ~/.zshenv
grep -qxF 'autoload -U compinit && compinit' ~/.zshrc || echo 'autoload -U compinit && compinit' >> ~/.zshrc
grep -qxF 'fpath=(~/.zsh/plugins/zsh-completions/src $fpath)' ~/.zshrc || echo 'fpath=(~/.zsh/plugins/zsh-completions/src $fpath)' >> ~/.zshrc