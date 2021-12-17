#!/usr/bin/env bash

export KEEP_ZSHRC='yes'

# set -e
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

platform='unknown'
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='mac'
fi

echo "force download oh my tmux and link the config"
rm -rf ~/.tmux > /dev/null
git clone https://github.com/gpakosz/.tmux.git ~/.tmux
ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf
ln -s -f $script_dir/tmux.conf.local ~/.tmux.conf.local

echo "force download the vim config and link the config"
rm -rf ~/.vim_runtime > /dev/null
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh


echo "force link the gitconfig"
rm ~/.gitignore > /dev/null
ln -s -f $script_dir/global_gitignore ~/.gitignore
rm ~/.gitconfig > /dev/null
ln -s -f $script_dir/gitconfig ~/.gitconfig

echo "copy the zshrc if it doesn't exsit"
cp -n $script_dir/zshrc ~/.zshrc
rm -rf ~/.oh-my-zsh > /dev/null
echo "download oh my zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

: '
if [[ ${platform} == 'linux' ]]; then
  ./ubuntu_tools.sh
fi
'
