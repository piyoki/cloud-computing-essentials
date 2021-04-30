#!/bin/bash

set -e

# welcome info
sudo apt install -y figlet >/dev/null 2>&1
echo -e "\033[0;35m$(figlet Nvim Cloud)"
echo -e "\033[1;37m
[WELCOME]  Welcome to Neovim Cloud Bootstrap Process !!
[AUTHOR]   Kevin Yu
[LICENSE]  MIT 2.0
[SOURCE]   github.com/yqlbu/cloud-computing-essentials
"
echo -e "\033[1;37m[INFO] Neovim Cloud configuration will start in 3 seconds ... \n"
sleep 3

init() {
  echo -e "[INFO] bootstrap process now started"

  echo ">>> updating package repositories"
  # packages update and installation
  sudo apt update >/dev/null 2>&1 && sudo apt upgrade -y >/dev/null 2>&1
  sudo apt-get install git software-properties-common -y >/dev/null 2>&1

  if [[ ! -x "$(command -v vim)" ]]; then
    echo ">>> vim not found, installing vim"
    sudo apt install vim -y >/dev/null 2>&1
  fi

  if [[ ! -x "$(command -v python)" ]]; then
    echo ">>> python environment not found, installing python"
    sudo apt install python3 python3-pip -y >/dev/null 2>&1
    # setup python bin and pip
    echo ">>> setting up python environment"
    sudo rm -rf /usr/bin/python && sudo ln -s /usr/bin/python3 /usr/bin/python
    sudo ln -s /usr/bin/pip3 /usr/bin/pip
  fi

  echo ">>> adding addtional package repositories"
  sudo add-apt-repository ppa:neovim-ppa/unstable -y >/dev/null 2>&1
  sudo add-apt-repository ppa:lazygit-team/release -y >/dev/null 2>&1
  sudo add-apt-repository ppa:bashtop-monitor/bashtop -y >/dev/null 2>&1

  echo ">>> installing node and npm"
  curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - >/dev/null 2>&1
  sudo apt-get update >/dev/null 2>&1 && apt-get install -y nodejs >/dev/null 2>&1

  echo ">>> installing essential packages"
  sudo apt install lazygit neovim golang bashtop -y >/dev/null 2>&1

  # install plugins
  echo ">>> installing neccessary plugin prerequisites"
  pip install -U pip >/dev/null 2>&1 
  pip install -U pynvim neovim-remote pylint ranger-fm >/dev/null 2>&1
  sudo npm install -g neovim vim-node-rpc \
      instant-markdown-d@next typescript bash-language-server --noconfirm >/dev/null 2>&1
}


# environment variables
REPO_URL=github.com/yqlbu/dotfiles
USER=$(logname)
USER_ID=$(id -u $(logname))
HOME=/home/$(logname)
DOT_PATH=/home/$(logname)/dotfiles
MINIMAP_URL_ARM64=https://github.com/wfxr/code-minimap/releases/download/v0.5.1/code-minimap_0.5.1_arm64.deb
MINIMAP_URL_AMD64=https://github.com/wfxr/code-minimap/releases/download/v0.5.1/code-minimap_0.5.1_amd64.deb

nvim_setup() {
  echo -e "\n[INFO] neovim configuration now started"
  mkdir -p $HOME/.vim
  mkdir -p $HOME/.config/nvim
  echo ">>> cloning source code from remote repository"
  git clone https://github.com/yqlbu/dotfiles.git $HOME/dotfiles >/dev/null 2>&1
  echo ">>> finished"
  cp -r ${DOT_PATH}/nvim/.config/nvim/* $HOME/.config/nvim
  echo ">>> installing neovim plugins"
  nvim --headless +PlugInstall +qall >/dev/null 2>&1
  echo ">>> finished"
}

# configure plugins settings
plugins_setup() {
  echo -e "\n[INFO] plugins configuration now started"
  # minimap
  if [[ $(lscpu | grep Architecture | awk '!/x86_64/{exit 1}') -ne 1 ]]; then
      curl -fSsL ${MINIMAP_URL_AMD64} -o minimap-install.deb && sudo dpkg -i minimap-install.deb >/dev/null 2>&1
  else
      curl -fSsL ${MINIMAP_URL_ARM64} -o minimap-install.deb && sudo dpkg -i minimap-install.deb >/dev/null 2>&1
      
  fi
  echo ">>> finished"
  rm -rf minimap-install.deb
  # ranger
  echo ">>> setting up ranger plugin"
  mkdir -p $HOME/.config/ranger
  cp -r ${DOT_PATH}/ranger/.config/ranger/* $HOME/.config/ranger
  echo ">>> finished"
  # lazygit
  echo ">>> setting up lazygit plugin"
  mkdir -p $HOME/.config/jesseduffield/lazygit
  cp -r ${DOT_PATH}/lazygit/.config/jesseduffield/lazygit/* $HOME/.config/jesseduffield/lazygit
  echo ">>> finished"
}

clearn_up() {
  echo -e "\n[INFO] clearning up"
  chown -R $USER:$USER_ID $HOME/.vim
  chown -R $USER:$USER_ID $HOME/.config
  chown -R $USER:$USER_ID $HOME/.LfCache
  chown -R $USER:$USER_ID $HOME/.cache
  rm -rf ${DOT_PATH}
  echo ">>> finished"
}

# execution
start=$(date +%s.%N)

init
nvim_setup
plugins_setup
clearn_up

end=$(date +%s.%N)    
runtime=$(python -c "print(${end} - ${start})")

echo -e "\n[INFO] neovim bootstrap done!"
echo ">>> duration was $runtime seconds"
