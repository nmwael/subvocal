import json, base64, os

screenshots_dir = 'screenshots'

repo = os.environ.get('GITHUB_REPOSITORY', 'nmwael/subvocal')
run_id = os.environ.get('GITHUB_RUN_ID', '0')
run_url = f'https://github.com/{repo}/actions/runs/{run_id}'
artifact_url = run_url

files = sorted(f for f in os.listdir(screenshots_dir) if f.endswith('.png'))
total_size = sum(os.path.getsize(os.path.join(screenshots_dir, f)) for f in files)

summary_lines = [
    '## Screenshots',
    '',
    f'**{len(files)}** screenshots captured from this test run (**{total_size / 1024:.0f} KB** total).',
    '',
    f'📥 **[Download integration-screenshots artifact]({artifact_url})** — extract the zip and open the included `index.html` to view.',
    '',
]

for f in files:
    path = os.path.join(screenshots_dir, f)
    name = f.replace('.png', '')
    size = os.path.getsize(path)
    summary_lines.append(f'- {name} ({size} bytes)')

summary_lines.append('')
print('\n'.join(summary_lines))
