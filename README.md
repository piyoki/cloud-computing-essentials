# cloud-computing-essentials

Essential bootstrap scripts and templates for cloud-computing usage cases

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
