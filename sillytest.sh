#!/bin/bash

# Download and prepare the LiteSpeedTest tool
curl -LO https://github.com/lilendian0x00/xray-knife/releases/download/v2.14.21/Xray-knife-linux-64.zip
unzip Xray-knife-linux-64.zip
./xray-knife net http -f output.txt -v -x csv -o valid.csv -t 10
# Process both output files
cat valid.csv | awk -F',' '$2 == "passed"' | awk -F',' '{print $1}' > output.txt
cat valid.csv | awk -F',' '$2 == "passed" && $3 == "tls"' | awk -F',' '{print $1}' > output_443.txt
