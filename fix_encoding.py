import re

path = r'f:\wujieVPN\Mihom\lib\mihom\desktop\pages\desktop_plans_page.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')
fixes = 0

for i, line in enumerate(lines):
    # Fix L1254: the 'Complete payment in' line
    if 'Complete payment in' in line:
        old = line
        # Replace entire line with clean version
        lines[i] = "          Text(S.isEn ? 'Complete payment in \${_payments[_selectedPayment].name}' : '\u8bf7\u5728\${_payments[_selectedPayment].name}\u4e2d\u5b8c\u6210\u652f\u4ed8',"
        print(f'Fixed L{i+1}: Complete payment line')
        fixes += 1

    # Fix devices garbled text
    if 'devices' in line and 'feats.add' in line and '\u53f0' not in line:
        # Check if it has garbled Chinese after "devices"
        if '\u9e3f\u53f0' in line or '\u5364' in line:
            lines[i] = line  # keep as is for now
        # Try to fix: "鍙拌澶?" pattern
        new_line = re.sub(r'"[^"]*\u53f0[^"]*(?:\?|[^\x00-\x7f])(?="|})', '"台设备"', line)
        if new_line != line:
            lines[i] = new_line
            print(f'Fixed L{i+1}: devices line')
            fixes += 1

# Broader fix: find all garbled Chinese patterns that break strings
# Pattern: text inside quotes that contains typical garbled sequences
for i, line in enumerate(lines):
    # Fix specific known garbled patterns with their corrections
    replacements = {
        '\u6d41\u91cf': '\u6d41\u91cf',  # already correct
    }

print(f'Total fixes: {fixes}')

# Now let's just look at what lines still have issues
for i, line in enumerate(lines):
    stripped = line.strip()
    # Check for unbalanced quotes in lines with Chinese
    if any(ord(c) > 0x4e00 for c in stripped):
        single_quotes = stripped.count("'")
        double_quotes = stripped.count('"')
        # Simple heuristic: strings in interpolation ${} don't count
        if single_quotes % 2 != 0:
            print(f'Odd single quotes L{i+1}: {stripped[:100]}')
        if double_quotes % 2 != 0:
            print(f'Odd double quotes L{i+1}: {stripped[:100]}')

with open(path, 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(lines))
print('File written')
