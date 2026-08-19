#!/usr/bin/env bash
# One-command setup for this repo's ingest stack. Idempotent — safe to re-run.
# Installs the two CLIs and the browser. The two MCP servers need no install:
# they are declared in .mcp.json and launched on demand by uvx/npx.
set -euo pipefail

command -v uv  >/dev/null || { echo "Missing 'uv'.  Install: https://docs.astral.sh/uv/getting-started/installation/"; exit 1; }
command -v npx >/dev/null || { echo "Missing 'npx'. Install Node.js: https://nodejs.org"; exit 1; }

echo "==> Installing Crawl4AI (crwl)"
uv tool install --upgrade crawl4ai
crawl4ai-setup            # downloads Chromium + stealth browser, inits local db

echo "==> Installing markitdown"
uv tool install --upgrade markitdown

echo "==> Ensuring Chromium for playwright-mcp"
# crawl4ai-setup usually already populated this shared cache; harmless if so.
npx -y playwright install chromium

cat <<'EOF'

Done. Verify with:
  claude mcp list                          # fetch + playwright should be Connected
  crwl https://example.com -o markdown
  markitdown --help

If 'crwl' is not found, add uv's tool dir to PATH:  uv tool update-shell
EOF
