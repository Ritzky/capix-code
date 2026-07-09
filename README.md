# Capix Code

A fork of [opencode](https://github.com/anomalyco/opencode) with a built-in Capix LLM provider — the CLI coding assistant for the Capix network. Bundled inside Capix IDE, or installable standalone.

## What is this?

Capix Code is a rebranded fork of opencode (the open-source AI coding agent) that ships with:

- **Capix branding** — the TUI shows the Capix ASCII art banner on launch, the status bar reads "Capix Code", the activity bar icon is the Capix hexagonal mark, and the color theme uses the brand palette (neon teal `#3DCED6`, green `#14F195`, deep slate-navy `#0a0e14`).
- **Built-in Capix provider** — the `capix` provider is pre-configured as the default, pointing at the Capix OpenAI-compatible gateway. No manual config needed.
- **Capix model catalog** — SuperGemma partner endpoints (Gemma 3 27B/12B/4B + CodeGemma) + community models (Qwen2.5-Coder, Llama 3.3 70B, etc.) are pre-listed in the model picker.
- **Auto-connect** — if you deployed an LLM in Capix IDE or on capix.network, the endpoint details sync automatically via env vars.
- **Covenant** — opencode's agent system + the Capix Covenant governance rules (no destructive actions without approval, always explain changes, match existing style) are injected as the system prompt.
- **Cross-platform** — standalone binaries for Mac, Windows, and Linux via Bun `--compile`.

## Install

### Standalone

```bash
curl -fsSL https://capix.network/install-code.sh | bash
```

Or with npm:

```bash
npm i -g capix-code
```

### Bundled in Capix IDE

Capix IDE ships with `capix-code` in its PATH — no separate install needed. Open the IDE's integrated terminal and type `capix-code`.

## Quick start

```bash
# Set your Capix endpoint + key (from capix.network → API Keys, or your deployed LLM)
export CAPIX_BASE_URL=https://capix.network/api/v1
export CAPIX_API_KEY=cpk_...     # for the gateway, OR cpxllm_... for a deployed LLM
export CAPIX_MODEL=capix/auto   # optional — defaults to "auto" (cheapest route)

# Launch
capix-code
```

For a self-deployed LLM endpoint:

```bash
export CAPIX_BASE_URL=http://94.23.x.x:12345/v1     # from /cloud/llm deploy result
export CAPIX_API_KEY=cpxllm_...                      # from the deploy response
export CAPIX_MODEL=capix/supergemma-gemma3-27b       # the model you deployed

capix-code
```

## How it works

Capix Code IS opencode — the entire TypeScript codebase is cloned, the binary is renamed from `opencode` to `capix-code`, config directories change from `~/.config/opencode/` to `~/.config/capix-code/`, env var prefixes change from `OPENCODE_` to `CAPIX_CODE_`, and a default config (`config/defaults.json`) is bundled that registers the `capix` provider with `@ai-sdk/openai-compatible`.

Everything opencode does — the TUI, agent system, tools, MCP, themes, skills, the entire feature set — works identically. The only difference is the provider is pre-configured for Capix.

## Building from source

```bash
git clone https://github.com/Ritzky/capix-code.git
cd capix-code
./scripts/bootstrap.sh    # clones opencode + applies rebrand + installs config
./scripts/dev.sh          # launches in dev mode (requires Bun 1.3+)
```

To build a standalone binary:

```bash
./scripts/build.sh        # produces dist/capix-code-<platform>/bin/capix-code
```

## Integration with Capix IDE

When Capix IDE boots, it:
1. Sets `CAPIX_CODE_*` env vars in all integrated terminals pointing at the user's session token + deployed endpoint.
2. Pre-writes `~/.config/capix-code/opencode.json` with the Capix provider config if none exists.
3. Makes `capix-code` available in the PATH (bundled binary or npm global).

So a user who installs Capix IDE and deploys an LLM gets `capix-code` working in the terminal with zero additional configuration.

## Config

The default config (`config/defaults.json`) registers:

- `capix` as the provider (via `@ai-sdk/openai-compatible`)
- `CAPIX_BASE_URL` env var as the base URL (defaults to `https://capix.network/api/v1`)
- `CAPIX_API_KEY` env var as the API key
- 8 pre-listed models (SuperGemma + community)
- `capix/auto` as the default model (cheapest route via the gateway)
- Edit/Ask permission mode (safe defaults)
- Autoupdate disabled (IDE manages updates)

Override anything in `~/.config/capix-code/opencode.json` or the project-level `capix-code.json`.

## License

Capix Code is a fork of opencode (MIT, Anomaly). Rebrand kit + config are Apache-2.0 (Capix). See `NOTICE`.

## Links

- **opencode** (upstream) — [github.com/anomalyco/opencode](https://github.com/anomalyco/opencode) · [opencode.ai](https://opencode.ai)
- **Capix Protocol** — [capix.network](https://capix.network)
- **Capix IDE** — [github.com/Ritzky/CapIX-IDE](https://github.com/Ritzky/CapIX-IDE)
