#  _   _                 _             ____
# | \ | | ___  _____   _(_)_ __ ___   / ___|  ___ _ ____   _____ _ __
# |  \| |/ _ \/ _ \ \ / / | '_ ` _ \  \___ \ / _ \ '__\ \ / / _ \ '__|
# | |\  |  __/ (_) \ V /| | | | | | |  ___) |  __/ |   \ V /  __/ |
# |_| \_|\___|\___/ \_/ |_|_| |_| |_| |____/ \___|_|    \_/ \___|_|
#
# https://github.com/yqlbu/neovim-server
#
# Copyright (C) 2020-2021 yqlbu <https://hikariai.net>
#
# This is a open-source software, liscensed under the MIT License.
# See /License for more information.

FROM ubuntu:latest

ENV TZ=America/LosAngeles \
    SHELL=/bin/bash \
    ADDUSER=true \
    SUDO=false \
    USER=guest \
    PASSWORD=password \
    CONTAINER=neovim

WORKDIR /root

# Determine Architecture
RUN ARCH=$(dpkg --print-architecture) && echo $ARCH > ./ARCH

# Install Common Software Packages
RUN apt-get update && apt-get install -y --no-install-recommends tzdata \
    sudo openssl curl openssh-client sshpass locales
RUN echo $TZ > /etc/timezone && apt-get install -y tzdata && \
    dpkg-reconfigure tzdata && locale-gen en_US.UTF-8 
RUN apt-get install -y --no-install-recommends git ca-certificates software-properties-common gnupg gnupg-agent
RUN apt-get install -y --no-install-recommends python3 build-essential make
RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
RUN apt-get update && apt-get install -y nodejs

# Install Essential Packages for Neovim
RUN sudo add-apt-repository ppa:neovim-ppa/unstable -y
RUN sudo add-apt-repository ppa:lazygit-team/release -y
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    wget python3-dev python3-pip golang neovim ranger lazygit
RUN rm -rf /usr/bin/pip && ln -s /usr/bin/pip3 /usr/bin/pip && \
    rm -rf /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python
RUN pip install -U pip && pip install -U \
    pynvim neovim-remote pylint
RUN if [ "$(cat ./ARCH)" = "amd64" ] ; then \
      wget https://github.com/wfxr/code-minimap/releases/download/v0.6.0/code-minimap_0.6.0_amd64.deb; \
      dpkg -i code-minimap_0.6.0_amd64.deb; \
      rm -rf code-minimap_0.6.0_amd64.deb; \
    else \
      wget https://github.com/wfxr/code-minimap/releases/download/v0.6.0/code-minimap_0.6.0_arm64.deb; \
      dpkg -i code-minimap_0.6.0_arm64.deb; \
      rm -rf code-minimap_0.6.0_arm64.deb; \
    fi
RUN npm install -g neovim vim-node-rpc
RUN npm install -g instant-markdown-d@next
RUN npm install -g typescript
RUN npm install -g bash-language-server
RUN sudo apt-get clean && \
    rm -rf /var/lib/apt/list/* /tmp/* /var/tmp/* && \
    rm -rf ./ARCH

# Setup Neovim

RUN echo "# BOOTSTRAP ENV" >> $HOME/.bashrc && \
    echo "alias ..='cd ..'" >> $HOME/.bashrc && echo "alias ...='cd ../../'" >> $HOME/.bashrc && \
    echo "alias vim='nvim'" >> $HOME/.bashrc && \
    echo "alias ra='ranger'" >> $HOME/.bashrc && \
    echo "alias lg='lazygit'" >> $HOME/.bashrc && \
    echo "export LANG=en_US.UTF-8" >> $HOME/.bashrc && \
    echo "export EDITOR=nvim" >> $HOME/.bashrc && \
    echo "export PATH=$HOME/.local/bin:$PATH" >> $HOME/.bashrc

RUN git clone https://github.com/yqlbu/neovim-server $HOME/neovim-server && \
    cp -r $HOME/neovim-server/nvim $HOME/.config/ && \
    cp -r $HOME/neovim-server/nvim/ranger $HOME/.config && \
    rm -rf $HOME/neovim-server

# Setup Neovim Plugins
RUN nvim --headless +PlugInstall +qall > /dev/null 2>&1

# Setup Neovim Coc-Extensions
ADD ./package.json /root/.config/coc/extensions/
RUN nvim '+CocInstall -sync coc-json'
RUN nvim +CocUpdateSync +qall

# ADD ./bootstrap.sh /usr/bin
# ADD ./static/neovim/bootstrap.sh /usr/bin
# RUN chmod u+x /usr/bin/bootstrap.sh

# ENTRYPOINT [ "bootstrap.sh" ]
CMD [ "bash" ]
