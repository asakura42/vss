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
)

MERGED_FILE="merge.txt"
FINAL_OUTPUT="output.txt"
FINAL_OUTPUT_443="output_443.txt"

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

sort -u "$MERGED_FILE" -o "$MERGED_FILE"

item_exists_in_array() {
	local item="$1"
	local array=("${!2}")

	for element in "${array[@]}"; do
		if [[ "$element" == "$item" ]]; then
			return 0
		fi
	done

	return 1
}

check_country() {
	local ip="$1"
	local country_code=$(geoiplookup "$ip" | awk -F ',' '{print $1}' | awk -F ' ' '{print $NF}')
	if [[ "$country_code" == "UA" || "$country_code" == "RU" || "$country_code" == "BE" || "$country_code" == "CN" ]]; then
		echo "FOUND $ip $country_code" 1>&2
		return  1
	else
		echo "OKAY $ip $country_code" 1>&2
		return  0
	fi
}


unique_identifiers=()

grep "^vmess:" "$MERGED_FILE" | sed 's|vmess://||' | while IFS= read -r line; do
json=$(echo "$line" | base64 -d 2>/dev/null  | jq -c 'select(.tls == "tls" and ."skip-cert-verify" == false and .net == "ws")' 2>/dev/null  )
if [[ -n "$json" ]]; then
	identifier=$(echo "$json" | jq -r '"\(.add):\(.port)"')
	ip_address=$(echo "$json" | jq -r '.add')
 		if check_country "$ip_address"; then

	if ! item_exists_in_array "$identifier" unique_identifiers[@]; then
			unique_identifiers+=("$identifier")
			if echo "$json" | jq -c 'select(.port == "443" or .port == 443)' ; then
				echo "$json" | base64 -w0 | sed 's|$|\n|;s|^|vmess://|' >> "$FINAL_OUTPUT_443"
			fi
			echo "$json" | base64 -w0 | sed 's|$|\n|;s|^|vmess://|' >> "$FINAL_OUTPUT"
		fi
	fi
fi
done

grep "^ss:" "$MERGED_FILE"  | while IFS= read -r line ; do
if echo "$line" | grep -oP '(?<=ss:\/\/)[^@]+' | awk 'length > 40' | base64 -d 2>/dev/null  | grep -q "2022-blake3\|ietf-poly1305" ; then
	domain=$(echo "$line" | awk -F'@' '{print $2}' | awk -F':' '{print $1}' )

	identifier=$(echo "$line" | grep -oP '(?<=@).*(?=#)')
 		if check_country "$domain"; then

	if ! item_exists_in_array "$identifier" unique_identifiers[@]; then
			unique_identifiers+=("$identifier")
			if echo "$line" | grep -q ":443#" ; then
				echo "$line" >> "$FINAL_OUTPUT_443"
			fi
			echo "$line" >> "$FINAL_OUTPUT"

		fi
	fi
fi
done

sort -ru "$FINAL_OUTPUT" -o "$FINAL_OUTPUT"
sort -ru "$FINAL_OUTPUT_443" -o "$FINAL_OUTPUT_443"
