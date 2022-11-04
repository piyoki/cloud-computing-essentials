# Cloud Scripts

## ACME Script

```bash
bash <(curl -L -s https://gitlab.com/rwkgyg/acme-script/raw/main/acme.sh)
```

## X-UI Script (Enhanced Version)

```bash
wget -N https://gitlab.com/rwkgyg/x-ui-yg/raw/main/install.sh && bash install.sh
```

## V2ray Agent Script

```bash
wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
```

## VPS DD Script

```bash
bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh') -d 9 -v 64 -p Xy12345678

# 命令中的 -d 后面为Debian版本号，-v 后面为64位/32位，【7、8、9、10】
# 命令中的 -u 后面为Ubuntu版本号，-v 后面为64位/32位，【14.04、16.04、18.04、20.04】
```

## Netflix Verify Script

https://github.com/sjlleo/netflix-verify

`amd64`

```bash
wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/v3.1.0/nf_linux_amd64 && chmod +x nf && ./nf
```

`arm64`

```bash
wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/v3.1.0/nf_linux_arm64 && chmod +x nf && ./nf
```

## Check Media Unlock Script

```bash
bash <(curl -L -s check.unlock.media)
```

## Warp Script

https://github.com/fscarmen/warp

```bash
wget -N https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh && bash menu.sh
```
