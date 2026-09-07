#!/bin/bash

# Install zsh-defer plugin
git clone --depth 1 https://github.com/romkatv/zsh-defer.git ~/.zsh/plugins/zsh-defer

CONFIG_FILE="$HOME/.zshrc"
cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

# Step 1: Perform substitutions
sed -i -E '
  s#^source ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh$#zsh-defer source ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh#
  s#^source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh$#zsh-defer source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh#
  s#^source ~/.zsh/plugins/fzf-tab/fzf-tab.plugin.zsh$#zsh-defer source ~/.zsh/plugins/fzf-tab/fzf-tab.plugin.zsh#
  s#^eval "\$\(zoxide init zsh\)"$#zsh-defer eval "\$(zoxide init zsh)"#
  s#^\[ -f ~/.fzf.zsh \] && source ~/.fzf.zsh$#[ -f ~/.fzf.zsh ] \&\& zsh-defer source ~/.fzf.zsh#
  s#^autoload -U compinit && compinit$#zsh-defer autoload -U compinit \&\& zsh-defer compinit#
' "$CONFIG_FILE"

# Step 2: Insert zsh-defer plugin loader before first usage
if ! grep -q '^source ~/.zsh/plugins/zsh-defer/zsh-defer.plugin.zsh' "$CONFIG_FILE"; then
  LINE_NUM=$(grep -n '^zsh-defer ' "$CONFIG_FILE" | head -n 1 | cut -d: -f1)
  if [ -z "$LINE_NUM" ]; then
    echo "source ~/.zsh/plugins/zsh-defer/zsh-defer.plugin.zsh" >> "$CONFIG_FILE"
  else
    sed -i "${LINE_NUM}i source ~/.zsh/plugins/zsh-defer/zsh-defer.plugin.zsh" "$CONFIG_FILE"
  fi
fi

rm "$CONFIG_FILE.bak"
