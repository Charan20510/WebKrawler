---
name: web-ingest
description: |
  Fetch, crawl, and convert web pages or local documents into clean LLM-ready
  markdown. Routes each request to the cheapest tool that can do the job and
  escalates only on failure. Use when asked to read a URL, scrape or crawl a
  site, ingest documentation, or convert a PDF/DOCX/XLSX/PPTX to markdown.
  All tools are free and local — no API keys, no paid services.
---

# Web ingest

Pick the cheapest tool that works. Escalate only when it fails.

## Routing ladder

Stop at the first rung that succeeds.

1. **Local file** (PDF, DOCX, XLSX, PPTX, image) → `markitdown <file>`
2. **Single URL** → `fetch` MCP (`mcp__fetch__fetch`)
3. **`fetch` returned empty / boilerplate / obviously-missing content** → the page is
   JS-rendered. Use `playwright` MCP.
4. **Page needs login, clicks, form fills, or a screenshot** → `playwright` MCP directly,
   skip rungs 2–3.
5. **Many pages from one site** → `crwl` CLI (see below).

Never reach for a paid service (Firecrawl hosted, Exa, Tavily, Serper). This stack is
free by design; if a rung fails, say so rather than substituting a paid tool.

## Commands

```bash
# local file → markdown
markitdown report.pdf > report.md

# one page
crwl https://example.com -o markdown

# whole site, capped at 50 pages, into one file
crwl https://example.com/docs --deep-crawl bfs --max-pages 50 -o markdown > docs.md
```

`crwl` flags worth knowing: `-o all|json|markdown|md|markdown-fit|md-fit`,
`--deep-crawl bfs|dfs|best-first`, `--max-pages N`, `-q "question"`, `-bc` (bypass cache).
Always pass `--max-pages` with `--deep-crawl` — it is unbounded otherwise.
Run `crwl --help` if a flag is uncertain — do not guess.

## Output convention

When saving ingested content to a file, prepend a provenance header:

```markdown
<!-- source: https://example.com/docs | fetched: 2026-08-19 | tool: crwl -d 2 -->
```

One file per source unless the user asks for a merged document.

## Report which tool you used

After ingesting, state in one line which rung you landed on and why, e.g.
"Used playwright — fetch returned an empty shell (JS-rendered)."
This keeps the cost of each ingest visible.

## Crawl etiquette

- Depth 2+ on a large site can mean hundreds of requests. Confirm with the user before
  crawling a site they don't own at depth > 1.
- Prefer targeting a docs subpath (`/docs`) over a bare domain.

## Boundaries

This skill is the fetch/convert layer. It does not decide *what* to research or
synthesise findings — that belongs to `deep-research` or the caller. Hand back clean
markdown and stop.
