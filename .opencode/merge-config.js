const fs = require('fs');
const path = require('path');

const basePath = path.join(__dirname, 'opencode-base.json');
const profilesDir = path.join(__dirname, 'profiles');
const outputPath = path.join(__dirname, '..', 'opencode.json');

const provider = process.argv[2];
if (!provider) {
  console.error('Usage: node .opencode/merge-config.js <provider>');
  console.error('Providers: google, groq, openrouter, opencode, nvidia');
  process.exit(1);
}

const profilePath = path.join(profilesDir, `${provider}.json`);
if (!fs.existsSync(profilePath)) {
  console.error(`Profile not found: ${profilePath}`);
  process.exit(1);
}

const base = JSON.parse(fs.readFileSync(basePath, 'utf-8'));
const profile = JSON.parse(fs.readFileSync(profilePath, 'utf-8'));

function merge(target, source) {
  for (const key of Object.keys(source)) {
    if (source[key] && typeof source[key] === 'object' && !Array.isArray(source[key])) {
      if (!target[key] || typeof target[key] !== 'object') target[key] = {};
      merge(target[key], source[key]);
    } else {
      target[key] = source[key];
    }
  }
  return target;
}

const merged = merge(base, profile);
fs.writeFileSync(outputPath, JSON.stringify(merged, null, 2) + '\n');
console.log(`Switched to ${provider} profile → ${outputPath}`);
