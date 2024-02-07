#!/bin/bash

URLS=(
    "plain|https://raw.githubusercontent.com/mahdibland/ShadowsocksAggregator/master/Eternity.txt"
    "b64|https://raw.githubusercontent.com/soroushmirzaei/telegram-configs-collector/main/protocols/vmess"
    "b64|https://raw.githubusercontent.com/mahdibland/SSAggregator/master/sub/sub_merge_base64.txt"
    "b64|https://raw.githubusercontent.com/barry-far/V2ray-Configs/main/All_Configs_base64_Sub.txt"
    "b64|https://raw.githubusercontent.com/ermaozi/get_subscribe/main/subscribe/v2ray.txt"
    "plain|https://raw.githubusercontent.com/peasoft/NoMoreWalls/master/list_raw.txt"
)

MERGED_FILE="merge.txt"
FINAL_OUTPUT="output.txt"

CURL_TIMEOUT=10

fetch_and_decode() {
    local type="$1"
    local url="$2"
    local output_file="$3"

    if [[ "$type" == "b64" ]]; then
        curl -m "$CURL_TIMEOUT" -Ls "$url" | base64 -d >> "$output_file"
    else
        curl -m "$CURL_TIMEOUT" -Ls "$url" >> "$output_file"
    fi
}

for item in "${URLS[@]}"; do
    IFS='|' read -ra ADDR <<< "$item"
    fetch_and_decode "${ADDR[0]}" "${ADDR[1]}" "$MERGED_FILE"
done

sort -u "$MERGED_FILE" -o "$MERGED_FILE"

grep "^vmess:" "$MERGED_FILE" | awk -F'/' '{print $NF}' | while IFS= read -r line; do
    echo "$line" | base64 -d 2>/dev/null | jq -c 'select(.tls == "tls" and ."skip-cert-verify" == false and .net == "ws")' 2>/dev/null
done | while IFS= read -r line; do
    echo "$line" | base64 -w0 | sed 's|$|\n|;s|^|vmess://|'
done >> "$FINAL_OUTPUT"

grep "^ss:" "$MERGED_FILE" | while IFS= read -r line ; do
    if echo "$line" | grep -oP '(?<=ss:\/\/)[^@]+' | awk 'length > 80' | base64 -d 2>/dev/null | grep -q "2022-blake3\|ietf-poly1305" ; then
        echo "$line" >> "$FINAL_OUTPUT"
    fi
done

sort -u "$FINAL_OUTPUT" -o "$FINAL_OUTPUT"
