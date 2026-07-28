#!/usr/bin/env bash
set -euo pipefail

RESULTS_FILE="${1:-integration-results.json}"
OUT_DIR="${2:-screenshots}"

mkdir -p "$OUT_DIR"
count=0
names=()

while IFS= read -r line; do
  [[ "$line" == \{* ]] || continue

  msg_type=$(echo "$line" | awk -F'"messageType"[[:space:]]*:[[:space:]]*"' '{print $2}' | cut -d'"' -f1)
  [[ "$msg_type" == "print" ]] || continue

  msg=$(echo "$line" | awk -F'"message"[[:space:]]*:[[:space:]]*"' '{print $2}' | cut -d'"' -f1)
  [[ "$msg" == SCREENSHOT:* ]] || continue

  IFS=':' read -r _ name _ <<< "$msg"
  b64=$(echo "$msg" | cut -d':' -f3-)
  path="$OUT_DIR/${name}.png"
  echo "$b64" | base64 -d > "$path"
  echo "  extracted: $path"
  names+=("$name")
  count=$((count + 1))
done < "$RESULTS_FILE"

gallery_path="$OUT_DIR/index.html"
{
cat <<'HEADER'
<!DOCTYPE html>
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
  .screenshot img { display: block; width: 100%; height: auto; }
</style>
</head>
<body>
<h1>Integration Test Screenshots</h1>
HEADER

for name in "${names[@]}"; do
  echo "<div class=\"screenshot\"><h2>${name}</h2><img src=\"${name}.png\" alt=\"${name}\"></div>"
done

cat <<'FOOTER'
</body>
</html>
FOOTER
} > "$gallery_path"

echo "Created gallery: $gallery_path"
echo "Extracted $count screenshot(s)"
