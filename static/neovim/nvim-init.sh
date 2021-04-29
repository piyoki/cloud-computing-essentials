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
echo -e "\n[INFO] bootstrap started!"

init() {
  echo -e "\n[INFO] bootstrap process now started"

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
DOT_PATH=$HOME/dotfiles
MINIMAP_URL_ARM64=https://github.com/wfxr/code-minimap/releases/download/v0.5.1/code-minimap_0.5.1_arm64.deb
MINIMAP_URL_AMD64=https://github.com/wfxr/code-minimap/releases/download/v0.5.1/code-minimap_0.5.1_amd64.deb

nvim_setup() {
  echo -e "\n[INFO] neovim configuration now started" && \
  mkdir -p $HOME/.vim && \
  mkdir -p $HOME/.config/nvim && \
  echo ">>> cloning source code from remote repository" && \
  git clone https://github.com/yqlbu/dotfiles.git $HOME/dotfiles && \ 
  echo ">>> finished" && \
  cp -r ${DOT_PATH}/nvim/.config/nvim/* ~/.config/nvim && \
  echo ">>> installing neovim plugins" && \
  nvim --headless +PlugInstall +qall | tee logs.txt >/dev/null 2>&1
}

# configure plugins settings
plugins_setup() {
  echo -e "\n[INFO] plugins configuration now started"
  # minimap
  echo ">>> installing minimap plugin"
  if [[ $(lscpu | grep Architecture | awk '!/x86_64/{exit 1}') -ne 1 ]]; then
      curl -fSsL ${MINIMAP_URL_AMD64} -o minimap-install.deb && sudo dpkg -i minimap-install.deb >/dev/null 2>&1
      rm -rf minimap-install.deb
  else
      curl -fSsL ${MINIMAP_URL_ARM64} -o minimap-install.deb && sudo dpkg -i minimap-install.deb >/dev/null 2>&1
      rm -rf minimap-install.deb
  fi
  # ranger
  echo ">>> setting up ranger plugin"
  cp -r ${DOT_PATH}/ranger/.config/ranger/* ~/.config/ranger
  # lazygit
  echo ">>> setting up lazygit plugin"
  cp -r ${DOT_PATH}/lazygit/.config/jesseduffield/lazygit/* ~/.config/jesseduffield/lazygit
}

clearn_up() {
  rm -rf ${DOT_PATH}
}

# execution
init
nvim_setup
plugins_setup
clearn_up

echo ">>> neovim bootstrap done!"
