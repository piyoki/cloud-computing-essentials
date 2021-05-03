<h1 align="center"> ☁️ Cloud Computing Essentials</h1>
<p align="center">
    <em>Essential bootstrap scripts and templates for cloud-computing usage cases</em>
</p>

<p align="center">
    <img src="https://img.shields.io/github/license/yqlbu/cloud-computing-essentials" alt="License"/>
    <a href="https://hub.docker.com/repository/docker/hikariai/nvim-server">
        <img src="https://img.shields.io/badge/Docker-19.03-blue" alt="Version">
    </a>
    <a href="https://github.com/neovim/neovim">
        <img src="https://img.shields.io/badge/neovim-0.5.0-violet.svg" alt="NeoVim"/>
    </a>
    <a href="https://github.com/yqlbu/cloud-computing-essentials">
        <img src="https://img.shields.io/github/last-commit/yqlbu/cloud-computing-essentials" alt="lastcommit"/>
    </a>
</p>

# cloud-computing-essentials

Essential bootstrap scripts and templates for cloud-computing usage cases

## Table of Contents

- [Bootstrap Scripts](#bootstrap-scripts)
  - [Neovim Cloud](#neovim-cloud)
- [Common Tools](#common-tools)
  - [Kubectl](#kubectl)

## Bootstrap Scripts

### Neovim Cloud

```
curl -fsSL https://get.hikariai.net/api/v1/neovim/ | sudo bash -
```

## Common Tools

### Kubectl

```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod u+x kubectl && sudo mv kubectl /usr/bin
```
