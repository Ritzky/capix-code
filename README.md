# Capix Code

A fork of [opencode](https://github.com/anomalyco/opencode) with a built-in Capix LLM provider — the CLI coding assistant for the Capix network. Bundled inside Capix IDE, or installable standalone.

## What is this?

Capix Code is a rebranded fork of opencode — the open-source AI coding agent. It IS opencode, with the binary renamed from `opencode` to `capix-code` and the Capix provider pre-configured as the default. Everything opencode does works identically.

### What's pre-configured

- **Capix branding** — the TUI shows the Capix ASCII art banner on launch with brand colors (neon teal `#3DCED6`, green `#14F195`), the Capix brand mark logo, and a full TUI color theme using the Capix brand palette (deep slate-navy canvas, teal accents, green success states)
- **Built-in Capix provider** — the `capix` provider is the default, using `@ai-sdk/openai-compatible`, pointing at the Capix OpenAI-compatible gateway. No manual config needed.
- **Capix model catalog** — 8 pre-listed models including auto-routing (cheapest), Gemma 3 variants (27B/12B/4B), CodeGemma 7B, Qwen2.5-Coder 7B/32B, and Llama 3.3 70B
- **Auto-connect** — Capix IDE sets `CAPIX_BASE_URL` and `CAPIX_API_KEY` env vars in launched terminals from its SecretStorage, so `capix-code` works with zero additional setup
- **Covenant governance** — safe defaults: edit/bash actions require approval, autoupdate disabled (IDE manages updates)

## Install

### Standalone

```bash
# Once published:
curl -fsSL https://capix.network/install-code.sh | bash
```

Or with npm:

```bash
npm i -g capix-code
```

### Bundled in Capix IDE

Capix IDE ships `capix-code` in its PATH. When you click "Capix: Launch Capix Code", the IDE opens a terminal with `CAPIX_BASE_URL`, `CAPIX_API_KEY`, and `CAPIX_MODEL` env vars pre-set from your auto-connected LLM endpoint, then runs `capix-code`.

## Quick start

```bash
# Using the Capix gateway (auto-routes to the cheapest model):
export CAPIX_BASE_URL=https://capix.network/api/v1
export CAPIX_API_KEY=cpk_...        # from capix.network → API Keys
# CAPIX_MODEL defaults to "capix/auto" (cheapest route)

capix-code
```

Or with a self-deployed LLM endpoint:

```bash
export CAPIX_BASE_URL=http://94.23.x.x:12345/v1     # from /cloud/llm deploy result
export CAPIX_API_KEY=cpxllm_...                      # from the deploy response
export CAPIX_MODEL=capix/supergemma-gemma3-27b       # the model you deployed

capix-code
```

## How it works

Capix Code IS opencode. The repo is a rebrand kit — `scripts/bootstrap.sh` clones the full opencode TypeScript/Bun monorepo, then `scripts/rebrand.sh` applies:

- Binary name: `opencode` → `capix-code`
- Config dirs: `~/.config/opencode/` → `~/.config/capix-code/`
- Env var prefixes: `OPENCODE_` → `CAPIX_CODE_`
- The Capix provider config (`config/defaults.json`) as the bundled default
- The Capix TUI theme (`themes/capix.toml`) with brand colors
- The Capix launch banner (`brand/banner.ts`) with ASCII art + ANSI brand colors

Everything opencode does — the TUI, agent system, tools, MCP, themes, skills, plugins, the entire feature set — works identically. The only difference is the provider is pre-configured for Capix.

## Building from source

Requires [Bun 1.3+](https://bun.sh).

```bash
git clone https://github.com/Ritzky/capix-code.git
cd capix-code
./scripts/bootstrap.sh    # clones opencode + applies rebrand + installs config + theme
./scripts/dev.sh          # launches in dev mode (Bun)
```

To build a standalone binary:

```bash
./scripts/build.sh        # produces dist/capix-code-<platform>/bin/capix-code
```

For CI/cross-platform release builds, tag a version:

```bash
git tag v1.0.0
git push origin v1.0.0
# The Release workflow builds mac (arm64/x64), linux (x64/arm64), windows (x64)
```

## Config

The default config (`config/defaults.json`) registers:

| Setting | Value |
|---|---|
| Provider ID | `capix` (via `@ai-sdk/openai-compatible`) |
| Base URL | `CAPIX_BASE_URL` env var (defaults to `https://capix.network/api/v1`) |
| API Key | `CAPIX_API_KEY` env var |
| Default Model | `CAPIX_MODEL` env var (defaults to `capix/auto` — cheapest route) |
| Small Model | `capix/supergemma-gemma3-4b` (for lightweight tasks like titles) |
| Permission Mode | `edit: ask`, `bash: ask` (safe defaults) |
| Autoupdate | Disabled (IDE manages updates) |

Override anything in `~/.config/capix-code/opencode.json` or the project-level `capix-code.json`. See [opencode docs](https://opencode.ai/docs/config/) for all config options.

## Integration with Capix IDE

When Capix IDE boots, it:
1. Sets `CAPIX_BASE_URL`, `CAPIX_API_KEY`, and `CAPIX_MODEL` env vars in the terminal launched by "Capix: Launch Capix Code" — values come from SecretStorage (the auto-connected LLM endpoint).
2. Pre-writes `~/.config/capix-code/opencode.json` with the Capix provider config on first run (if no user config exists).
3. Pre-installs the `capix-code` binary in the PATH (bundled in the IDE or via npm global).

So a user who installs Capix IDE, connects their wallet, and deploys an LLM gets `capix-code` working in the terminal with zero additional configuration.

## License

- **opencode** (upstream): MIT, Copyright Anomaly.
- **Capix Code rebrand kit** (this repo — scripts, config, themes, brand): Apache-2.0, Copyright 2026 Capix.

See `NOTICE`. The "opencode" name is a trademark of Anomaly and is NOT used by Capix Code — the binary is rebranded to `capix-code`.

## Links

- **opencode** (upstream) — [github.com/anomalyco/opencode](https://github.com/anomalyco/opencode) · [opencode.ai](https://opencode.ai)
- **Capix Protocol** — [capix.network](https://capix.network) · [github.com/Ritzky/Capix-Protocol](https://github.com/Ritzky/Capix-Protocol)
- **Capix IDE** — [github.com/Ritzky/CapIX-IDE](https://github.com/Ritzky/CapIX-IDE)
