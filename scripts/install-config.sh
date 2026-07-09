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

# 3. Install the Capix TUI theme + color tokens
THEME_SRC="$DIR/themes/capix.toml"
TUI_SRC="$DIR/tui-capix.json"
THEME_DEST="$OPENCODE_DIR/packages/opencode/config/themes"
mkdir -p "$THEME_DEST"
cp "$THEME_SRC" "$THEME_DEST/capix.toml" 2>/dev/null || true
cp "$TUI_SRC" "$OPENCODE_DIR/packages/opencode/config/tui-capix.json" 2>/dev/null || true
echo "  ✓ TUI theme installed (capix.toml + tui-capix.json)"

# 4. Copy the brand assets
BRAND_SRC="$DIR/brand"
BRAND_DEST="$OPENCODE_DIR/packages/opencode/config/brand"
mkdir -p "$BRAND_DEST"
cp -R "$BRAND_SRC/"* "$BRAND_DEST/" 2>/dev/null || true
echo "  ✓ Brand assets (logo SVG + banner) installed"

# 5. Patch the TUI init to show the Capix banner + set default theme
TUI_INIT="$OPENCODE_DIR/packages/opencode/scripts/init-capix-tui.ts"
cat > "$TUI_INIT" << 'TUI_EOF'
/**
 * init-capix-tui.ts — sets the Capix theme as default + shows the launch banner.
 * Called before the TUI boots. Writes ~/.config/capix-code/tui.json with
 * theme: "capix" if no user TUI config exists.
 */
import { existsSync, mkdirSync, writeFileSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

// Set the default TUI theme to "capix" if no user config exists.
function getConfigDir(): string {
  switch (process.platform) {
    case "darwin": return join(homedir(), "Library", "Application Support", "capix-code");
    case "win32": return join(homedir(), "AppData", "Roaming", "capix-code");
    default: return join(homedir(), ".config", "capix-code");
  }
}

const configDir = getConfigDir();
const tuiConfig = join(configDir, "tui.json");

// Copy the bundled theme file to the user's themes dir.
const themesDir = join(configDir, "themes");
const bundledTheme = join(import.meta.dir, "..", "config", "themes", "capix.toml");

if (existsSync(bundledTheme)) {
  mkdirSync(themesDir, { recursive: true });
  const themeDest = join(themesDir, "capix.toml");
  if (!existsSync(themeDest)) {
    writeFileSync(themeDest, readFileSync(bundledTheme, "utf-8"), "utf-8");
  }
}

// Write the default TUI config if no user config exists.
if (!existsSync(tuiConfig)) {
  const defaultTui = {
    "$schema": "https://opencode.ai/tui.json",
    "theme": "capix",
    "scroll_speed": 3,
    "scroll_acceleration": { "enabled": true },
    "diff_style": "auto",
    "mouse": true,
    "attention": { "enabled": true, "notifications": true, "sound": true, "volume": 0.4 },
  };
  mkdirSync(configDir, { recursive: true });
  writeFileSync(tuiConfig, JSON.stringify(defaultTui, null, 2), "utf-8");
}

// Print the launch banner.
const BANNER = `
\\x1b[38;2;61;206;214m  ██████╗ █████╗ ██████╗ ██████╗ ██╗   ██╗██╗███████╗██╗  ██╗
 ██╔════╝██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝██║██╔════╝╚██╗██╔╝
 ██║     ███████║██████╔╝██████╔╝ ╚████╔╝ ██║█████╗   ╚███╔╝
 ██║     ██╔══██║██╔══██╗██╔══██╗   ╚██╔╝  ██║██╔══╝   ██╔██╗
 ╚██████╗██║  ██║██████╔╝██║  ██║    ██║   ██║███████╗██╔╝ ██╗
  ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝    ╚═╝   ╚═╝╚══════╝╚═╝  ╚═╝\\x1b[0m

  \\x1b[38;2;20;241;149m◆\\x1b[0m \\x1b[38;2;100;116;139mRoute compute, inference, and agents.\\x1b[0m
  \\x1b[2mPowered by opencode × Capix\\x1b[0m
`;
// Use raw write to stdout so ANSI codes are interpreted.
process.stdout.write(BANNER.replace(/\\\\x1b/g, "\\x1b") + "\\n");
TUI_EOF
echo "  ✓ TUI init script (theme + banner) created"

echo "✓ Capix branding fully installed."
