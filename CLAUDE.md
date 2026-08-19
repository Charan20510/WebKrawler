# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

There is no application code here. This directory is a **workspace for web-scraping and
research tooling** — it holds notes and configuration for a free, fully-local ingest stack.
Do not infer a build system, test suite, or framework; none exists. If asked to add code,
ask what it should do rather than assuming a scraper implementation is wanted.

Everything needed to reproduce this setup on another device lives in this folder and is
committed to git — see `README.md` for the clone → `setup.sh` flow. Only two things are
machine-local and gitignored: `.claude/settings.local.json` and the installed binaries
(`crwl`, `markitdown`, Chromium), which `setup.sh` reinstalls per device.

Contents:

- `firecrawl-research.md` — competitive research on Firecrawl vs. OSS alternatives, with
  pricing, licenses, and star/commit data as of 2026-08-19. Treat its figures as a dated
  snapshot; re-verify before relying on them.
- `utils.md` — day-to-day cheatsheet for the ingest stack.
- `.mcp.json` — project-scoped `fetch` + `playwright` MCP server definitions.
- `.claude/settings.json` — auto-enables those two servers on a fresh clone.
- `.claude/skills/web-ingest/SKILL.md` — the routing skill, committed and tunable.
- `setup.sh` — installs `crwl`, `markitdown`, and Chromium on a new device.

## The ingest stack

Four free, local tools are installed and wired up. Two are MCP servers, two are CLIs.
None require an API key or account.

| Tool | Type | Use for |
|---|---|---|
| `fetch` | MCP | one static URL → markdown |
| `playwright` | MCP | JS-rendered pages, logins, clicks, screenshots |
| `crwl` (Crawl4AI) | CLI | crawling many pages from one site |
| `markitdown` | CLI | local PDF/DOCX/XLSX/PPTX → markdown |

### Routing rule

Escalate only on failure — do not start at the heaviest tool:

1. Local file → `markitdown`
2. Single URL → `fetch`
3. `fetch` returns an empty shell or boilerplate → the page is JS-rendered, use `playwright`
4. Login / clicking / form-filling / screenshot needed → `playwright` directly
5. Many pages from one site → `crwl`

The `web-ingest` skill, committed at `.claude/skills/web-ingest/SKILL.md`, encodes this
ladder. Prefer invoking it over hand-rolling the routing. Tune behaviour by editing that
file and committing — it travels with the repo.

### Constraint: nothing paid

This stack was chosen explicitly so that no step ever costs money or requires signup.
Do not substitute Firecrawl's hosted API, Exa, Tavily, or Serper when a local tool fails —
report the failure instead. The `firecrawl` MCP server is enabled but runs keyless
(Search/Scrape/Parse only, under usage limits); treat it as a last resort, not a default.

## Commands

```bash
# single page
crwl https://example.com -o markdown

# deep crawl — ALWAYS cap with --max-pages, it is unbounded otherwise
crwl https://example.com/docs --deep-crawl bfs --max-pages 50 -o markdown > docs.md

# local document
markitdown report.pdf > report.md

# verify MCP servers are live
claude mcp list
```

`crwl` output formats: `all|json|markdown|md|markdown-fit|md-fit`. Other useful flags:
`--deep-crawl bfs|dfs|best-first`, `-q "question"`, `-bc` (bypass cache).
Run `crwl --help` rather than guessing a flag — several plausible ones (e.g. `-d` for depth)
do not exist.

## Conventions

- When saving ingested content, prepend a provenance comment:
  `<!-- source: <url> | fetched: <date> | tool: <command> -->`
- State which routing rung was used and why, so the cost of each ingest stays visible.
- Confirm before deep-crawling a site the user does not own; depth crawls can issue
  hundreds of requests.

## New device setup

```bash
git clone <repo>
cd WebKrawler
bash setup.sh
claude mcp list   # fetch + playwright should show Connected, from .mcp.json
```
