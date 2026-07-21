import base64, os

screenshots_dir = 'screenshots'

repo = os.environ.get('GITHUB_REPOSITORY', 'nmwael/subvocal')
run_id = os.environ.get('GITHUB_RUN_ID', '0')
run_url = f'https://github.com/{repo}/actions/runs/{run_id}'
artifact_url = run_url

files = sorted(f for f in os.listdir(screenshots_dir) if f.endswith('.png'))
total_size = sum(os.path.getsize(os.path.join(screenshots_dir, f)) for f in files)

lines = [
    '## Screenshots',
    '',
    f'**{len(files)}** screenshots captured from this test run (**{total_size / 1024:.0f} KB** total).',
    '',
    f'📥 **[Download full-size screenshots artifact]({artifact_url})**',
    '',
    '| # | Screenshot | Name |',
    '|---|-----------|------|',
]

for i, f in enumerate(files, 1):
    path = os.path.join(screenshots_dir, f)
    name = f.replace('.png', '')
    with open(path, 'rb') as img:
        b64 = base64.b64encode(img.read()).decode()
    lines.append(f'| {i} | <img src="data:image/png;base64,{b64}" width="240"> | `{name}` |')

lines.append('')
print('\n'.join(lines))
