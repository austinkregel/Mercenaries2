import re

def main():
    with open('out/print_hex_chunks.txt', 'r') as f:
        content = f.read()
    
    # Extract the hex part inside the double quotes after [runtime]
    match = re.search(r'\[runtime\] <tt=2 val=\w+> "(.*?)"', content, re.DOTALL)
    if not match:
        # Try finding the first line starting with 1B4C756151
        lines = []
        started = False
        for line in content.splitlines():
            line = line.strip().replace('"', '')
            if '1B4C756151' in line:
                # Extract starting from 1B4C756151
                idx = line.find('1B4C756151')
                lines.append(line[idx:])
                started = True
            elif started:
                if '<<<' in line or not line:
                    break
                lines.append(line)
        hex_str = ''.join(lines)
    else:
        hex_str = match.group(1).replace('\n', '').replace('\r', '').replace(' ', '')
    
    # Strip any trailing/leading quotes or non-hex chars
    hex_str = re.sub(r'[^0-9A-Fa-f]', '', hex_str)
    
    print("Hex string length:", len(hex_str))
    print("Hex prefix:", hex_str[:40])
    print("Hex suffix:", hex_str[-40:])
    
    data = bytes.fromhex(hex_str)
    with open('out/textwidget_new.bc', 'wb') as f:
        f.write(data)
    print("Successfully wrote out/textwidget_new.bc")

if __name__ == '__main__':
    main()
