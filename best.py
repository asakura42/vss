import re

# Define the sets for encryption methods and excluded countries
shadowsocks_encryptions = {
    "2022-blake3-aes-256-gcm",
    "2022-blake3-chacha20-poly1305",
    "chacha20-ietf-poly1305",
    "xchacha20-ietf-poly1305"
}

excluded_countries = {"RU", "UA", "BE", "CN"}

# Read the debug.txt file
with open('debug.txt', 'r') as debug_file:
    debug_data = debug_file.read()

# Split the debug.txt content into blocks
blocks = debug_data.split("\n\n")

# List to store matching configuration numbers
matching_config_numbers = []

# Process each block to find matching configurations
for block in blocks:

    config_match = re.search(r"Config Number:\s*(\d+)", block)
    if not config_match:
        continue
    config_number = config_match.group(1)

    protocol_match = re.search(r"Protocol:\s*(\w+)", block)
    if not protocol_match:
        continue
    protocol = protocol_match.group(1)

    if protocol == "shadowsocks":
        encryption_match = re.search(r"Encryption:\s*([^\n]+)", block)
        if encryption_match and encryption_match.group(1) in shadowsocks_encryptions:
            matching_config_numbers.append(int(config_number))

    elif protocol == "vmess":
        network_match = re.search(r"Network:\s*(\w+)", block)
        tls_match = re.search(r"TLS:\s*(\w+)", block)
        if network_match and tls_match:
            network = network_match.group(1)
            tls = tls_match.group(1)
            if network == "ws" and tls == "tls":
                matching_config_numbers.append(int(config_number))

    elif protocol == "vless":
        flow_match = re.search(r"Flow:\s*([^\n]+)", block)
        tls_match = re.search(r"TLS:\s*(\w+)", block)
        if flow_match and tls_match:
            flow = flow_match.group(1)
            tls = tls_match.group(1)
            if flow == "xtls-rprx-vision" and tls == "reality":
                matching_config_numbers.append(int(config_number))

# Sort the matching configuration numbers
matching_config_numbers.sort()

# Read the output.txt file to get specific lines
with open('output.txt', 'r') as output_file:
    output_lines = output_file.readlines()

# Get the lines from output.txt corresponding to matching config numbers
matched_lines = []
for line_number in matching_config_numbers:
    if 1 <= line_number <= len(output_lines):
        matched_lines.append(output_lines[line_number - 1].strip())

# Read valid.csv and process its lines
final_results = []
with open('valid.csv', 'r') as csv_file:
    csv_lines = csv_file.readlines()
    for csv_line in csv_lines:
        columns = csv_line.strip().split(',')
        if len(columns) < 2:  # Ensure there are at least two columns (first and last)
            continue
        first_column = columns[0].strip()
        last_column = columns[-1].strip()

        # Check if the first column matches any of the matched lines
        # and if the last column is not in excluded_countries
        if first_column in matched_lines and last_column not in excluded_countries:
            final_results.append(csv_line.strip())

# Output the full list of matching lines
print("\n".join(final_results))
