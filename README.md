# webcrawler

Free, fully-local web ingest stack for Claude Code — no API keys, no paid services.
See `CLAUDE.md` for the full routing rules and `utils.md` for a daily-use cheatsheet.

## Setup (new device)

```bash
git clone <this-repo>
cd webcrawler
bash setup.sh
claude mcp list   # fetch + playwright should show Connected
```

Requires `uv` and `node`/`npx` already installed.

## What's in here

| File | Purpose |
|---|---|
| `.mcp.json` | project-scoped `fetch` + `playwright` MCP servers |
| `.claude/settings.json` | auto-enables those servers on clone |
| `.claude/skills/web-ingest/` | the routing skill — edit this to tune behaviour |
| `setup.sh` | installs the two CLIs (`crwl`, `markitdown`) + Chromium |
| `CLAUDE.md` | rules for Claude Code working in this repo |
| `utils.md` | human-readable cheatsheet |
| `firecrawl-research.md` | dated research on Firecrawl vs. OSS alternatives |

## Tuning

Edit `.claude/skills/web-ingest/SKILL.md`, commit, pull on other devices.
