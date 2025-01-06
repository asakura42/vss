#!/bin/bash

URLS=(
	"plain|https://raw.githubusercontent.com/mahdibland/ShadowsocksAggregator/master/Eternity.txt"
	"b64|https://raw.githubusercontent.com/soroushmirzaei/telegram-configs-collector/main/protocols/vmess"
	"plain|https://raw.githubusercontent.com/ermaozi/get_subscribe/main/subscribe/v2ray.txt"
	"plain|https://raw.githubusercontent.com/peasoft/NoMoreWalls/master/list_raw.txt"
	"b64|https://raw.githubusercontent.com/mfuu/v2ray/master/v2ray"
	"b64|https://raw.githubusercontent.com/ripaojiedian/freenode/main/sub"
 	"b64|https://raw.githubusercontent.com/peasoft/NoMoreWalls/master/list.txt"
   	"b64|https://raw.githubusercontent.com/soroushmirzaei/telegram-configs-collector/main/protocols/reality"
)

MERGED_FILE="merge.txt"
FINAL_OUTPUT="output.txt"

CURL_TIMEOUT=30

fetch_and_decode() {
	local type="$1"
	local url="$2"
	local output_file="$3"

	if [[ "$type" == "b64" ]]; then
		curl -m "$CURL_TIMEOUT" -Ls "$url" | base64 -d | python split_lines.py | tee >(wc -l) >> "$output_file"
	else
		curl -m "$CURL_TIMEOUT" -Ls "$url" | python split_lines.py | tee >(wc -l) >> "$output_file"
	fi
}

for item in "${URLS[@]}"; do
	IFS='|' read -ra ADDR <<< "$item"
	fetch_and_decode "${ADDR[0]}" "${ADDR[1]}" "$MERGED_FILE"
done

sed -i 's|\&amp;|\&|g' "$MERGED_FILE"

sort -u "$MERGED_FILE" -o "$FINAL_OUTPUT"

