#!/usr/bin/env bash
#
# bootstrap.sh — clone opencode and prepare the capix-code fork.
#
# opencode is a TypeScript/Bun monorepo at github.com/anomalyco/opencode.
# This script clones it, applies the capix-code rebrand, and bundles the
# Capix provider as the default config.
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
OPENCODE_DIR="${OPENCODE_DIR:-$DIR/opencode}"
OPENCODE_REF="${OPENCODE_REF:-dev}"

if [ -d "$OPENCODE_DIR/.git" ]; then
  echo "✓ $OPENCODE_DIR already cloned."
  exit 0
fi

echo "▸ Cloning opencode into $OPENCODE_DIR (ref: $OPENCODE_REF)…"
git clone --depth 1 --branch "$OPENCODE_REF" https://github.com/anomalyco/opencode.git "$OPENCODE_DIR"

echo "▸ Applying capix-code rebrand…"
bash "$DIR/scripts/rebrand.sh"

echo "▸ Installing Capix default config…"
bash "$DIR/scripts/install-config.sh"

echo "✓ Bootstrap complete. Run ./scripts/dev.sh to launch, or ./scripts/build.sh to package."
