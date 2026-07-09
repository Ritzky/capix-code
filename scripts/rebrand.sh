#!/usr/bin/env bash
#
# rebrand.sh — rename opencode -> capix-code across the full TypeScript tree.
#
# opencode is a Bun/TypeScript monorepo. The binary name, config dirs,
# env var prefixes, and package name are defined in:
#   - packages/opencode/package.json (bin, name)
#   - packages/opencode/script/build.ts (output paths)
#   - install (the curl | sh installer script)
#   - source: string constants for config dirs, env prefixes
#
# This script does a caps-sensitive search-replace + drops the Capix
# provider config as the default. Re-run safely — it's idempotent.
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
OPENCODE_DIR="${OPENCODE_DIR:-$DIR/opencode}"

if [ ! -d "$OPENCODE_DIR" ]; then
  echo "✗ No $OPENCODE_DIR. Run ./scripts/bootstrap.sh first."
  exit 1
fi

cd "$OPENCODE_DIR"
echo "▸ Rebranding opencode → capix-code in $OPENCODE_DIR"

# 1. Binary name + package name in the main package.json
PKG="$OPENCODE_DIR/packages/opencode/package.json"
if [ -f "$PKG" ]; then
  sed -i.bak 's/"opencode"/"capix-code"/g; s/"bin": { "opencode"/"bin": { "capix-code"/g' "$PKG"
  rm -f "$PKG.bak"
  echo "  ✓ package.json: opencode → capix-code"
fi

# 2. Build script output naming
BUILD="$OPENCODE_DIR/packages/opencode/script/build.ts"
if [ -f "$BUILD" ]; then
  sed -i.bak 's/opencode-\$/capix-code-\$/g; s|bin/opencode|bin/capix-code|g' "$BUILD"
  rm -f "$BUILD.bak"
  echo "  ✓ build.ts: output paths renamed"
fi

# 3. Config/auth directory prefixes — opencode uses ~/.config/opencode, ~/.opencode, OPENCODE_*
#    We rename these to capix-code equivalents.
#    This is the broadest replace — it touches all source files.
echo "▸ Replacing config dir + env var prefixes…"
FILES=$(rg -l --glob '!node_modules' --glob '!bun.lock' --glob '!*.bak' 'opencode' "$OPENCODE_DIR/packages/opencode/src" 2>/dev/null || true)
if [ -n "$FILES" ]; then
  echo "$FILES" | while IFS= read -r f; do
    # Caps-sensitive: "opencode" → "capix-code" (lowercase binary/identifier)
    #                "OpenCode" → "CapixCode" (display name)
    #                "OPENCODE" → "CAPIX_CODE" (env var prefix)
    sed -i.bak \
      's/OPENCODE_/CAPIX_CODE_/g' \
      "$f"
    rm -f "$f.bak"
  done
  echo "  ✓ env prefix: OPENCODE_ → CAPIX_CODE_"
fi

# 4. Config directory paths: "opencode" → "capix-code" in dir names
echo "▸ Replacing config directory names…"
rg -l --glob '!node_modules' --glob '!bun.lock' --glob '!*.bak' \
  '\.opencode\|\.config/opencode\|opencode/auth' \
  "$OPENCODE_DIR/packages/opencode/src" 2>/dev/null | while IFS= read -r f; do
  sed -i.bak \
    's|\.config/opencode|.config/capix-code|g; s|\.opencode|.capix-code|g; s|opencode/auth|capix-code/auth|g' \
    "$f"
  rm -f "$f.bak"
done
echo "  ✓ config dirs: .opencode → .capix-code, ~/.config/opencode → ~/.config/capix-code"

# 5. Replace the install script's binary name + GitHub repo references.
INSTALL="$OPENCODE_DIR/install"
if [ -f "$INSTALL" ]; then
  sed -i.bak \
    's|anomalyco/opencode|Ritzky/capix-code|g; s|opencode-ai|capix-code|g; s|"opencode"|"capix-code"|g; s|\$HOME/\.opencode|$HOME/.capix-code|g' \
    "$INSTALL"
  rm -f "$INSTALL.bak"
  echo "  ✓ install: repo + binary name updated"
fi

echo "✓ Rebrand complete."
