# Secure Proxy List for Vmess and Shadowsocks

This repository provides an auto-updating proxy list for Vmess and Shadowsocks, specifically designed to filter out less secure protocols in favor of more secure ones. It also employs obfuscation techniques to further enhance the security and privacy of your data.

```
https://raw.githubusercontent.com/asakura42/vss/master/output.txt?v=1
```

## Emphasis on Vmess `ws+tls`

The primary focus is on Vmess, particularly the `ws+tls` protocol. Vmess `ws+tls` is considered the best choice due to its combination of the WebSocket (ws) protocol and Transport Layer Security (tls) protocol. This combination ensures fast data transmission and robust encryption for secure communication. Additionally, the use of ws+tls incorporates obfuscation, making the traffic appear as regular HTTPS traffic, thereby bypassing most firewalls and network restrictions while adding an extra layer of security.

## Recommended Shadowsocks Protocols

In addition to Vmess, the list includes recommended Shadowsocks protocols such as `2022-blake3-aes-256-gcm`, `2022-blake3-chacha20-poly1305` (as recommended by the Xray project), and `chacha20-ietf-poly1305`, `xchacha20-ietf-poly1305`. These protocols are known for their strong security features and are recommended for users prioritizing data protection. Shadowsocks protocols do not support obfuscation by default, but may be good if you don't mind about your traffic. Also, due to large number of Shadowsocks providers, they are filtered by password length.

Every server's default port is 443.

## Recommended software

*rays:
```
xray
```

Frontends:
```
v2raya
nekoray
```
