#!/bin/bash

# Download and prepare the LiteSpeedTest tool
curl -LO https://github.com/xxf098/LiteSpeedTest/releases/download/v0.15.0/lite-linux-amd64-v0.15.0.gz
gzip -dk lite-linux-amd64-v0.15.0.gz
chmod +x ./lite-linux-amd64-v0.15.0

# Create the configuration file
echo '{ "concurrency": 10, "timeout": 16, "outputMode": 3, "unique": true, "speedtestMode":"pingonly", "pingMethod":"tcpping" }' > config.json

# Function to process a file in batches
process_file() {
    rm temp.txt
    local input_file=$1
    local base_name=$(basename "$input_file" .txt)
    local line_count=$(wc -l < "$input_file")
    local batch_size=500
    local batch_number=0

    # Split the file into batches and process each batch
    for ((i=0; i<line_count; i+=batch_size)); do
        batch_number=$((i / batch_size))
        batch_file="${base_name}_batch_${batch_number}.txt"

        # Create a batch file
        sed -n "$((i + 1)),$((i + batch_size))p" "$input_file" > "$batch_file"

        # Run the LiteSpeedTest on the batch file
        ./lite-linux-amd64-v0.15.0 -config config.json -test "$batch_file"

        # Process the output
        cat output.json | jq -r '.nodes[]|select(.max_speed > 0) | .link' >> temp.txt
    done
}

# Process both output files
process_file "output.txt"
sort -u temp.txt -o output.txt
process_file "output_443.txt"
sort -u temp.txt -o output_443.txt 

