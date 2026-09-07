sudo apt -y install zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone git@github.com:zdharma-zmirror/fast-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
git clone git@github.com:zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone git@github.com:zsh-users/zsh-completions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions

echo -e "export PATH=\$PATH:/home/$(whoami)/.local/bin" >> ~/.zshrc
echo 'eval "$(oh-my-posh init --config '~/.cache/oh-my-posh/themes/atomic.omp.json' zsh)"' >> ~/.zshrc

#### Enable plugins in .zshrc
# plugins=(... fast-syntax-highlighting zsh-autosuggestions zsh-completions)