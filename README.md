<h1 align="center"> ☁️ Cloud Computing Essentials</h1>
<p align="center">
    <em>Essential bootstrap scripts and templates for cloud-computing usage cases</em>
</p>

<p align="center">
    <img src="https://img.shields.io/github/license/yqlbu/cloud-computing-essentials?color=critical" alt="License"/>
    <a href="https://hits.seeyoufarm.com">
      <img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fyqlbu%2Fcloud-computing-essentials&count_bg=%238C8C8B&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false"/>
    </a>
    <a href="https://img.shields.io/tokei/lines/github/yqlbu/cloud-computing-essentials?color=orange">
      <img src="https://img.shields.io/tokei/lines/github/yqlbu/cloud-computing-essentials?color=orange" alt="lines">
    </a>
    <a href="https://hub.docker.com/repository/docker/hikariai/">
        <img src="https://img.shields.io/badge/docker-v20.10-blue" alt="Version">
    </a>
    <a href="https://github.com/neovim/neovim">
        <img src="https://img.shields.io/badge/kubernetes-v1.21-navy.svg" alt="Kubernetes"/>
    </a>
    <a href="https://github.com/yqlbu/cloud-computing-essentials">
        <img src="https://img.shields.io/github/last-commit/yqlbu/cloud-computing-essentials" alt="lastcommit"/>
    </a>

</p>

## Navigation

comping soon

## Bootstrap Scripts

<details><summary>Neovim Cloud</summary>

</br>

```bash
curl -fsSL https://get.hikariai.net/api/neovim | sudo bash -
```

</p></details>

## Common Tools

<details><summary>Helm</summary>

</br>

```bash
$ sudo wget -qO- https://get.docker.com/ | sh
$ sudo usermod -aG docker $USER
$ sudo systemctl enable docker
```

</p></details>

<details><summary>Kubectl</summary>

</br>

```bash
$ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
$ sudo chmod u+x kubectl && sudo mv kubectl /usr/bin
```

</p></details>

<details><summary>Helm</summary>

</br>

```bash
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
$ sudo chmod u+x get_helm.sh
$ ./get_helm.sh
```

</p></details>

## License

[MIT (C) Kevin Yu](https://github.com/yqlbu/cloud-computing-essentials/blob/master/LICENSE)
