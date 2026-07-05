import json, base64, os, sys

results_file = sys.argv[1] if len(sys.argv) > 1 else 'integration-results.json'
out_dir = sys.argv[2] if len(sys.argv) > 2 else 'screenshots'

os.makedirs(out_dir, exist_ok=True)
count = 0

with open(results_file) as f:
    for line in f:
        line = line.strip()
        if not line.startswith('{'):
            continue
        try:
            e = json.loads(line)
        except json.JSONDecodeError:
            continue
        if e.get('messageType') != 'print':
            continue
        msg = e.get('message', '')
        if msg.startswith('SCREENSHOT:'):
            parts = msg.split(':', 2)
            if len(parts) >= 3:
                path = os.path.join(out_dir, f'{parts[1]}.png')
                with open(path, 'wb') as out:
                    out.write(base64.b64decode(parts[2]))
                print(f'  extracted: {path}')
                count += 1

print(f'Extracted {count} screenshot(s)')
