#!/bin/bash
# TODO fix
 curl -LO https://github.com/xxf098/LiteSpeedTest/releases/download/v0.15.0/lite-linux-amd64-v0.15.0.gz
 gzip -dk lite-linux-amd64-v0.15.0.gz
 chmod +x ./lite-linux-amd64-v0.15.0
 echo '{ "concurrency":10, "timeout":5, "outputMode": 3 }' > config.json
 ./lite-linux-amd64-v0.15.0 -config config.json -test ./output.txt
 cat output.json | jq -r '.nodes[]|select(.max_speed > 0) | .link' > output.txt

 ./lite-linux-amd64-v0.15.0 -config config.json -test ./output_443.txt
 cat output.json | jq -r '.nodes[]|select(.max_speed > 0) | .link' > output_443.txt

true
