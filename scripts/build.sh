#!/usr/bin/env bash
#
# build.sh — produce standalone capix-code binaries for the current platform.
#
# opencode uses Bun --compile to produce single-file executables.
# Output: dist/capix-code-<platform>/bin/capix-code
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
OPENCODE_DIR="${OPENCODE_DIR:-$DIR/opencode}"

if [ ! -d "$OPENCODE_DIR" ]; then
  echo "✗ No $OPENCODE_DIR. Run ./scripts/bootstrap.sh first."
  exit 1
fi

cd "$OPENCODE_DIR"

echo "▸ Building capix-code standalone binary…"
bun install
bun run packages/opencode/scripts/init-capix-config.ts 2>/dev/null || true
bun run --cwd packages/opencode script/build.ts --single

# Find the output — handle renamed patterns from the rebrand script.
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m | sed 's/x86_64/x64/;s/aarch64/arm64/' | sed 's/arm64/arm64/')
OUTPUT=$(find packages/opencode/dist -name "capix-code" -type f 2>/dev/null | head -1)

if [ -z "$OUTPUT" ]; then
  # Try the original naming in case the rebrand didn't catch build.ts output
  OUTPUT=$(find packages/opencode/dist -name "opencode" -type f 2>/dev/null | head -1)
  if [ -n "$OUTPUT" ]; then
    # Rename it
    NEW_OUTPUT=$(dirname "$OUTPUT")/capix-code
    mv "$OUTPUT" "$NEW_OUTPUT"
    OUTPUT="$NEW_OUTPUT"
  fi
fi

if [ -f "$OUTPUT" ]; then
  echo "✓ Build complete: $OUTPUT"
  echo "  Test it: CAPIX_BASE_URL=https://capix.network/api/v1 CAPIX_API_KEY=cpk_... $OUTPUT --help"
else
  # Fallback: check for any capix-code binary
  OUTPUT=$(find packages/opencode/dist -name "capix-code" -type f 2>/dev/null | head -1)
  if [ -n "$OUTPUT" ]; then
    echo "✓ Build complete: $OUTPUT"
  else
    echo "✗ Build failed — check output above"
    exit 1
  fi
fi
