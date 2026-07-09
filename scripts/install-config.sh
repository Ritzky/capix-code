#!/usr/bin/env bash
#
# install-config.sh — drop the Capix provider config as the default
# so capix-code users get Capix models out of the box.
#
# Two layers:
# 1. A bundled defaults.json in the capix-code package → acts as the
#    default if no user config exists.
# 2. A post-install hook that writes ~/.config/capix-code/opencode.json
#    (the merged config path) on first run.
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
OPENCODE_DIR="${OPENCODE_DIR:-$DIR/opencode}"
CONFIG_SRC="$DIR/config/defaults.json"

if [ ! -f "$CONFIG_SRC" ]; then
  echo "✗ Missing $CONFIG_SRC"
  exit 1
fi

# 1. Bundle the config into the opencode package as a default.
DEST_DIR="$OPENCODE_DIR/packages/opencode/config"
mkdir -p "$DEST_DIR"
cp "$CONFIG_SRC" "$DEST_DIR/capix-defaults.json"
echo "  ✓ bundled capix-defaults.json into packages/opencode/config/"

# 2. Patch the config loader to fall back to the bundled defaults
#    if no user config exists. This is a targeted patch — we add a
#    try/catch around the config load that reads the bundled file.
LOADER="$OPENCODE_DIR/packages/opencode/src/index.ts"
if [ -f "$LOADER" ]; then
  # We can't safely sed-patch TypeScript here without reading the file.
  # Instead, we create a wrapper script that writes the default config
  # to ~/.config/capix-code/ on first run before exec'ing capix-code.
  WRAPPER="$OPENCODE_DIR/packages/opencode/scripts/init-capix-config.ts"
  mkdir -p "$(dirname "$WRAPPER")"
  cat > "$WRAPPER" << 'WRAPPER_EOF'
/**
 * init-capix-config.ts — ensures the Capix provider config exists
 * at ~/.config/capix-code/opencode.json before the main app starts.
 * If a user config already exists, it's left untouched (merged at runtime).
 */
import { existsSync, mkdirSync, writeFileSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

function getConfigDir(): string {
  switch (process.platform) {
    case "darwin": return join(homedir(), "Library", "Application Support", "capix-code");
    case "win32": return join(homedir(), "AppData", "Roaming", "capix-code");
    default: return join(homedir(), ".config", "capix-code");
  }
}

const configDir = getConfigDir();
const configFile = join(configDir, "opencode.json");

// Only write if no user config exists — don't clobber.
if (!existsSync(configFile)) {
  // Try to read bundled defaults.
  let defaults = "{}";
  try {
    defaults = readFileSync(join(import.meta.dir, "..", "config", "capix-defaults.json"), "utf-8");
  } catch { /* bundled config missing — empty default */ }

  mkdirSync(configDir, { recursive: true });
  writeFileSync(configFile, defaults, "utf-8");
}
WRAPPER_EOF
  echo "  ✓ created init-capix-config.ts wrapper"
fi

echo "✓ Capix provider config installed."
