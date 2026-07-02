#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== subvocal dev setup ===${NC}"

# Check Flutter
if command -v flutter &>/dev/null; then
  echo -e "${GREEN}✓${NC} Flutter $(flutter --version 2>/dev/null | head -1)"
else
  echo -e "${YELLOW}⚠${NC} Flutter not found — install via: flutter SDK"
fi

# Check Dart
if command -v dart &>/dev/null; then
  echo -e "${GREEN}✓${NC} Dart $(dart --version 2>&1)"
else
  echo -e "${YELLOW}⚠${NC} Dart not found"
fi

# Check GitHub CLI
if command -v gh &>/dev/null; then
  echo -e "${GREEN}✓${NC} GitHub CLI $(gh --version 2>&1 | head -1)"
else
  echo -e "${RED}✗${NC} GitHub CLI not found"
fi

# Activate opencode profile
echo ""
echo -e "${GREEN}Activating opencode profile...${NC}"
node .opencode/merge-config.js opencode

echo ""
echo -e "${GREEN}Setup complete. Run 'flutter pub get' when source files exist.${NC}"
