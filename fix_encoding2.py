path = r'f:\wujieVPN\Mihom\lib\mihom\desktop\pages\desktop_plans_page.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')
fixes = 0

for i, line in enumerate(lines):
    # Fix L1476: devices garbled text
    if 'devices' in line and 'feats.add' in line:
        # The line should be: feats.add('${m.deviceLimit} ${S.isEn ? "devices" : "台设备"}');
        old = line
        # Find and replace the garbled part
        import re
        new_line = re.sub(
            r'"鍙拌澶\?}',  # garbled 台设备 with eaten closing "
            '"台设备"}',
            line
        )
        if new_line != old:
            lines[i] = new_line
            print(f'Fixed L{i+1} (regex): {new_line.strip()}')
            fixes += 1
        else:
            # Try another approach - find any line matching the pattern
            if '"鍙' in line:
                # Just replace the entire feats.add line
                indent = len(line) - len(line.lstrip())
                lines[i] = ' ' * indent + "feats.add('${m.deviceLimit} ${S.isEn ? \"devices\" : \"台设备\"}');"
                print(f'Fixed L{i+1} (full replace): {lines[i].strip()}')
                fixes += 1
    
    # Also fix L1474 if still garbled: traffic
    if 'traffic' in line and 'feats.add' in line and '娴侀噺' in line:
        indent = len(line) - len(line.lstrip())
        lines[i] = ' ' * indent + "feats.add('$trafficStr ${S.isEn ? \"traffic\" : \"流量\"}');"
        print(f'Fixed L{i+1} (traffic): {lines[i].strip()}')
        fixes += 1

print(f'Total fixes: {fixes}')

# Verify: check for remaining unbalanced quotes
for i, line in enumerate(lines):
    stripped = line.strip()
    if any(ord(c) > 0x4e00 for c in stripped):
        double_quotes = stripped.count('"')
        if double_quotes % 2 != 0:
            print(f'STILL ODD double quotes L{i+1}: {stripped[:120]}')

with open(path, 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines))
print('File written')
