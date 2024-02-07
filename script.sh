#!/bin/bash

URLS=(
    "https://raw.githubusercontent.com/mahdibland/ShadowsocksAggregator/master/Eternity.txt"
    "https://raw.githubusercontent.com/soroushmirzaei/telegram-configs-collector/main/protocols/vmess"
    "https://raw.githubusercontent.com/barry-far/V2ray-Configs/main/All_Configs_base64_Sub.txt"
    "https://raw.githubusercontent.com/ermaozi/get_subscribe/main/subscribe/v2ray.txt"
    "https://raw.githubusercontent.com/peasoft/NoMoreWalls/master/list_raw.txt"
)

MERGED_FILE="merge.txt"
FINAL_OUTPUT="output.txt"

CURL_TIMEOUT=10

fetch_and_decode() {
    local url="$1"
    local output_file="$2"

    if [[ "$url" =~ base64 ]]; then
        curl -m "$CURL_TIMEOUT" -Ls "$url" | base64 -d >> "$output_file"
    else
        curl -m "$CURL_TIMEOUT" -Ls "$url" >> "$output_file"
    fi
}

for url in "${URLS[@]}"; do
    fetch_and_decode "$url" "$MERGED_FILE"
done

sort -u "$MERGED_FILE" -o "$MERGED_FILE"

grep "^vmess:" "$MERGED_FILE" | awk -F'/' '{print $NF}' | while IFS= read -r line; do
    echo "$line" | base64 -d 2>/dev/null | jq -c 'select(.tls == "tls" and ."skip-cert-verify" == false and .net == "ws")' 2>/dev/null
done | while IFS= read -r line; do
    echo "$line" | base64 -w0 | sed 's|$|\n|;s|^|vmess://|'
done >> "$FINAL_OUTPUT"

grep "^ss:" "$MERGED_FILE" | while IFS= read -r line ; do
    if echo "$line" | grep -oP '(?<=ss:\/\/)[^@]+'  | base64 -d 2>/dev/null | grep -q "2022-blake3\|ietf-poly1305" ; then
        echo "$line" >> "$FINAL_OUTPUT"
    fi
done


sort -u "$FINAL_OUTPUT" -o "$FINAL_OUTPUT"
