# Cloud Scripts

## Cloudflare Warp

Reference: http://pkg.cloudflareclient.com/install

```bash
curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
apt update
apt install cloudflare-warp
warp-cli register
warp-cli set-mode proxy
warp-cli connect
curl ifconfig.me --proxy socks5://127.0.0.1:40000
```

<details><summary>xray config</summary>
</br>

```json
{
   "outbounds": [
       {
           "protocol": "freedom",
           "settings": {}
       },
       {
           "tag": "stream",
           "sendThrough": "0.0.0.0",
           "protocol": "socks",
           "settings": {
               "servers": [
                   {
                       "address": "127.0.0.1",
                       "port": 40000,
                       "users": []
                   }
               ]
           }
       }
   ],
   "routing": {
       "rules": [
           {
               "ip": [
                   "geoip:private"
               ],
               "outboundTag": "blocked",
               "type": "field"
           },
           {
               "type": "field",
               "domains": [
                   "geosite:netflix"
               ],
               "outboundTag": "stream"
           }
       ]
   }
}
```

restart xray

```
systemctl restart xray
```

</details>

<details><summary>inspect unlock status</summary>
</br>

```bash
# original ip
./nf
# with warp ip
./nf -proxy socks5://127.0.0.1:40000
```

</details>

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
