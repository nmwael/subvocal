import json, base64, os, sys

results_file = sys.argv[1] if len(sys.argv) > 1 else 'integration-results.json'
out_dir = sys.argv[2] if len(sys.argv) > 2 else 'screenshots'

os.makedirs(out_dir, exist_ok=True)
count = 0
names = []

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
                name = parts[1]
                path = os.path.join(out_dir, f'{name}.png')
                with open(path, 'wb') as out:
                    out.write(base64.b64decode(parts[2]))
                print(f'  extracted: {path}')
                names.append(name)
                count += 1

gallery_path = os.path.join(out_dir, 'index.html')
with open(gallery_path, 'w') as g:
    g.write('''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Integration Test Screenshots</title>
<style>
  body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px; background: #f5f5f5; }
  h1 { color: #333; }
  .screenshot { margin: 20px 0; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); overflow: hidden; }
  .screenshot h2 { margin: 0; padding: 12px 16px; background: #f0f0f0; font-size: 14px; color: #555; border-bottom: 1px solid #ddd; }
  .screenshot img { display: block; width: 100%%; height: auto; }
</style>
</head>
<body>
<h1>Integration Test Screenshots</h1>
''')
    for name in names:
        g.write(f'<div class="screenshot"><h2>{name}</h2><img src="{name}.png" alt="{name}"></div>\n')
    g.write('</body>\n</html>\n')

print(f'Created gallery: {gallery_path}')
print(f'Extracted {count} screenshot(s)')
