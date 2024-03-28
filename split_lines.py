import sys

def process_proxy_lines(data):
    data = data.replace("ss://", "\nss://")\
               .replace("trojan://", "\ntrojan://")\
               .replace("vless://", "\nvless://")\
               .replace("vmess://", "\nvmess://")

    lines = data.split('\n')
    corrected_lines = []

    for i in range(len(lines)):
        line = lines[i].strip()

        if (line.endswith("vle") or line.endswith("vme")) and i+1 < len(lines):
            if line.endswith("vle"):
                lines[i+1] = "vle" + lines[i+1]
            if line.endswith("vme"):
                lines[i+1] = "vme" + lines[i+1]
        else:
            corrected_lines.append(line)

    corrected_lines = list(filter(None, corrected_lines))
    return "\n".join(corrected_lines)

def main():
    input_data = "".join(sys.stdin.readlines())
    processed_data = process_proxy_lines(input_data)
    print(processed_data)

if __name__ == "__main__":
    main()
