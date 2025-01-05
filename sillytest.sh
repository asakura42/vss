#!/bin/bash

# Download and prepare the LiteSpeedTest tool
curl -LO https://github.com/lilendian0x00/xray-knife/releases/download/v2.14.21/Xray-knife-linux-64.zip
unzip Xray-knife-linux-64.zip -x README.md
./xray-knife net http -f output.txt -x csv -o valid.csv --rip --speedtest --sort false > debug.txt
sed -i '1d' valid.csv
python best.py > output.txt
