#!/bin/bash

URLS=(
	"plain|https://raw.githubusercontent.com/mahdibland/ShadowsocksAggregator/master/Eternity.txt"
        "plain|https://raw.githubusercontent.com/Epodonios/v2ray-configs/main/All_Configs_Sub.txt"
	"plain|https://raw.githubusercontent.com/SoliSpirit/v2ray-configs/refs/heads/main/all_configs.txt"
	"b64|https://raw.githubusercontent.com/soroushmirzaei/telegram-configs-collector/main/protocols/vmess"
	"b64|https://raw.githubusercontent.com/mahdibland/SSAggregator/master/sub/sub_merge_base64.txt"
	"b64|https://raw.githubusercontent.com/barry-far/V2ray-Configs/main/All_Configs_base64_Sub.txt"
	"b64|https://raw.githubusercontent.com/ermaozi/get_subscribe/main/subscribe/v2ray.txt"
	"plain|https://raw.githubusercontent.com/peasoft/NoMoreWalls/master/list_raw.txt"
	"b64|https://raw.githubusercontent.com/mfuu/v2ray/master/v2ray"
	"b64|https://raw.githubusercontent.com/mheidari98/.proxy/main/all"
	"b64|https://raw.githubusercontent.com/ripaojiedian/freenode/main/sub"
 	"b64|https://raw.githubusercontent.com/peasoft/NoMoreWalls/master/list.txt"
  	"plain|https://raw.githubusercontent.com/Hosseinsavior/Mysub/main/all_configs/all_configs.txt"
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

sort -u "$MERGED_FILE" -o "$FINAL_OUTPUT"

