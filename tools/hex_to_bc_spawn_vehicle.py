import re

def main():
    with open('out/disasm_spawn_vehicle.txt', 'r') as f:
        content = f.read()
    
    # Extract the hex part inside the double quotes after [runtime]
    match = re.search(r'\[runtime\] <tt=2 val=\w+> "(.*?)"', content, re.DOTALL)
    if not match:
        lines = []
        started = False
        for line in content.splitlines():
            line = line.strip().replace('"', '')
            if '1B4C756151' in line:
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
    
    hex_str = re.sub(r'[^0-9A-Fa-f]', '', hex_str)
    
    data = bytes.fromhex(hex_str)
    with open('out/spawn_vehicle.bc', 'wb') as f:
        f.write(data)
    print("Successfully wrote out/spawn_vehicle.bc")

if __name__ == '__main__':
    main()
