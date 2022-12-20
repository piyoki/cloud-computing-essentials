# Cloudflare Argo Tunnel Setup

- [Introduction](#introduction)
- [References](#references)
- [Prerequisites](#prerequisite)
- [Argo Tunnel Setup](#argo-tunnel-setup-via-the-command-line)
  - [Install cloudflared](#install-cloudflared)
  - [Authenticate cloudflared](#authenticate-cloudflared)
  - [Create a tunnel](#create-a-tunnel-and-give-it-a-name)
  - [Create a configuration file](#create-a-configuration-file)
  - [Run cloudflared as a service](#run-cloudflared-as-a-service)
  - [Check the tunnel](#check-the-tunnel)
- [Traefik Setup](#traefik-setup)
  - [Install Docker and Docker-Compose](#install-docker-and-docker-compose)
  - [Obtain CloudFlare DNS API Token](#obtain-cloudFlare-dns-api-token)
  - [Configure Traefik](#configure-traefik)
  - [Spin up the traefik container instance](#spin-up-the-traefik-container-instance)
- [Add Addtional Routes](#add-additional-reverse-proxy-routes)

## Introduction

This gist aims to walk you through the process of setting up `reverse-proxy` via [Cloudflare Argo Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/) and [Traefik](https://traefik.io/) on your VPS.

## References

- [Cloudflared - Set up a tunnel locally](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/)

## Prerequisites

- VPS (Ubunutu 22.04 recommended | 1VCPU 1G RAM >=10G SSD)
- Cloudflare Account (https://dash.cloudflare.com/sign-up)

Before you start, make sure you:

-[Add a website to Cloudflare](https://developers.cloudflare.com/fundamentals/get-started/setup/add-site/). -[Change your domain nameservers to Cloudflare](https://support.cloudflare.com/hc/en-us/articles/205195708).

---

## Argo Tunnel Setup via the Command Line

First, download `cloudflared` on your machine. Visit the downloads page to find the right package for your OS.

### Install cloudflared

```bash
# debian install
$ wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && dpkg -i cloudflared-linux-amd64.deb

# rpm install
$ wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-x86_64.rpm
```

### Authenticate cloudflared

```bash
$ cloudflared tunnel login
```

Running this command will:

- Open a browser window and prompt you to log in to your Cloudflare account. After logging in to your account, select your hostname.
- Generate an account certificate, the `cert.pem` file, in the default cloudflared directory at `~/.cloudflared`.

#### Create a tunnel and give it a name

```bash
$ sudo -i
$ cloudflared tunnel create <NAME>
```

Running this command will:

- Create a tunnel by establishing a persistent relationship between the name you provide and a UUID for your tunnel. At this point, no connection is active within the tunnel yet.
- Generate a tunnel credentials file in the default cloudflared directory.
- Create a subdomain of .cfargotunnel.com.
  From the output of the command, take note of the tunnel’s UUID and the path to your tunnel’s credentials file.

Confirm that the tunnel has been successfully created by running:

```bash
$ cloudflared tunnel list
```

### Create a configuration file

Create a [configuration file](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-useful-terms/#configuration-file) in your `/root/.cloudflared` directory using any text editor. This file will configure the tunnel to route traffic from a given origin to the hostname of your choice.

```ym
# ~/.cloudflared/config.yml

tunnel: <UUID>
credentials-file: /root/.cloudflared/<UUID>.json
ingress:
  - service: https://<PUBLIC_IP_OF_YOUR_VPS>
    originRequest:
      originServer: <DOMAIN_OF_YOUR_VPS e.g example.com>
      noTLSVerify: true

```

### Run cloudflared as a service

Install the cloudflared service.

```bash
$ cloudflared service install
```

Enable and start the service.

```bash
$ systemctl enable cloudflared --now
```

(Optional) View the status of the service.

```bash
$ systemctl status cloudflared
```

### Check the tunnel

Your tunnel configuration is complete! If you want to get information on the tunnel you just created, you can run:

```bash
$ cloudflared tunnel info <TUNNEL UUID>
```

## Traefik Setup

### Install Docker and Docker-Compose

```bash
# Install Docker
$ sudo wget -qO- https://get.docker.com/ | sh
$ sudo usermod -aG docker $USER
$ newgrp docker
$ sudo systemctl enable docker --now

# Install Docker-Compose
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
$ sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

### Obtain CloudFlare DNS API Token

To get started creating an API Token, log in to the [Cloudflare dashboard](https://dash.cloudflare.com/) and go to User Profile -> API Tokens or [click here](https://dash.cloudflare.com/profile/api-tokens). From the API Token home screen select `Use template` and the `Edit zone DNS` template.

In `Zone Resources`, select the zone (domain) you would like to include -> `Continue to summary` -> Save the token for later use.

### Prepare Docker-Compose File

```yml
# /etc/traefik/docker-compose.yml

version: "3.4"

services:
  traefik:
    image: traefik
    container_name: traefik
    restart: unless-stopped
    environment:
      CF_DNS_API_TOKEN: <YOUR_API_TOKEN_GOES_HERE>
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - /etc/localtime:/etc/localtime
      - /etc/traefik:/etc/traefik
```

### Configure Traefik

Create default config directory

```bash
$ sudo -i
$ mkdir -p /etc/traefik
$ mkdir -p /etc/traefik/certs
```

Edit `/etc/traefik/traefik.yml`

```yaml
# /etc/traefik/traefik.yml
---
api:
  dashboard: true
  debug: true

entryPoints:
  http:
    address: ":80"
  https:
    address: ":443"

serversTransport:
  insecureSkipVerify: true

providers:
  file:
    directory: /etc/traefik
    watch: true

tls:
  options:
    default:
      minVersion: VersionTLS12
      preferServerCipherSuites: true
  stores:
    default:
      defaultCertificate:
        certFile: /etc/traefik/certs/<YOUR_DOMAIN>.pem
        keyFile: /etc/traefik/certs/<YOUR_DOMAIN>.key

pilot:
  dashboard: false

http:
  routers:
    main:
      rule: "Host(`<YOUR_DOMAIN>`) && PathPrefix(`/`)"
      service: main
      middlewares:
        - default-headers
      tls:
        domains:
          - main: "<YOUR_DOMAIN>"
      entryPoints:
        - https

     <OTHER_CUSTOM_ROUTES_GOES_HERE>

  services:
    main:
      loadBalancer:
        servers:
          - url: "http://<YOUR_VPS_PUBLIC_IP>:3000"

    <OTHER_CUSTOM_SERVICE_GOES_HERE>

  middlewares:
    https-redirect:
      redirectScheme:
        scheme: https

    default-headers:
      headers:
        accessControlAllowMethods: ["GET", "POST", "OPTIONS"]
        accessControlMaxAge: 100
        accessControlAllowHeaders: "*"
        addVaryHeader: "true"
        frameDeny: true
        sslRedirect: true
        browserXssFilter: true
        contentTypeNosniff: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
        stsSeconds: 15552000
        customRequestHeaders:
          X-Forwarded-Proto: https

    secured:
      chain:
        middlewares:
          - default-whitelist
          - default-headers
```

### Spin up the traefik container instance

```bash
$ docker-compose up -d --force-recreate
```

## Add additional reverse proxy routes

Log in to the [Cloudflare dashboard](https://dash.cloudflare.com/) and navigate to `DNS` -> `Add record`:

- Select `CNAME` as the type
- Put you domain that points to the tunnel
- Toggle the `Proxy Status` to the `Proxied` state

e.g.

![](https://nrmjjlvckvsb.compat.objectstorage.ap-tokyo-1.oraclecloud.com/picgo/2022/08-21-da10b60c90aa45d16280fac440d39209.png)

In the `/etc/traefik/traefik.yml` file, follow the default config pattern and add additional routes and services.
