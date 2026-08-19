# Daily-use cheatsheet — free scraping stack

Four tools. Two are MCP servers (Claude uses them automatically). Two are CLIs (Claude shells out to them, or you run them yourself).

## 1. `fetch` MCP — read one web page

- **What it's for:** grabbing a single page as clean markdown. Fast, lightweight.
- **When:** docs pages, blog posts, GitHub READMEs, articles, API references.
- **How you use it:** just ask in plain English. No command needed.
  > "Read https://docs.python.org/3/library/asyncio.html and summarise the task API"
- **Limit:** no JavaScript. If a page comes back empty or looks broken → it's a JS site, use `playwright`.

## 2. `playwright` MCP — drive a real browser

- **What it's for:** pages that need a real browser — JS-rendered content, logins, clicking, forms, screenshots.
- **When:** dashboards, single-page apps, anything behind a login, "click through and tell me what happens".
- **How you use it:**
  > "Open localhost:3000, log in with these creds, and screenshot the settings page"
  > "This React page won't load in fetch — use playwright and get me the pricing table"
- **Cost:** slower and heavier than `fetch`. Don't reach for it first.

## 3. `crwl` (Crawl4AI CLI) — crawl a whole site

- **What it's for:** many pages at once → markdown. This is the free Firecrawl replacement.
- **When:** ingesting a full docs site, building a local knowledge base, bulk research.
- **How you use it:**
  ```bash
  crwl https://example.com/docs -o markdown              # one page
  crwl https://example.com/docs -o markdown > docs.md    # save it

  # follow links across the site, capped at 50 pages
  crwl https://example.com/docs --deep-crawl bfs --max-pages 50 -o markdown > docs.md
  ```
  Or just ask: *"crawl the FastAPI docs site into a single markdown file"* — Claude runs `crwl` for you.
- **Always pass `--max-pages`** with `--deep-crawl`, or it runs unbounded.
- **Note:** be polite on sites you don't own — a deep crawl can mean hundreds of requests.

## 4. `markitdown` — local files → markdown

- **What it's for:** PDFs, Word, Excel, PowerPoint, images → markdown Claude can read.
- **When:** you have a file on disk, not a URL.
- **How you use it:**
  ```bash
  markitdown report.pdf > report.md
  markitdown sheet.xlsx > sheet.md
  ```
  Or: *"convert ~/Downloads/contract.pdf to markdown and summarise the payment terms"*

## Pick the right one

| You have… | Use |
|---|---|
| One URL, static page | `fetch` MCP |
| One URL, JS / login / clicking | `playwright` MCP |
| A whole site to ingest | `crwl` |
| A file on your disk | `markitdown` |
| No URL yet, need to find sources | built-in `WebSearch` |

**Default order:** `fetch` → if it fails, `playwright`. `crwl` only when you need many pages.

## Typical daily flows

- **Learn a new library:** `crwl <docs-site> -d 2 -o markdown > lib.md`, then ask questions against the file.
- **Read one article:** just paste the URL and ask.
- **Debug your own running app:** ask Claude to open it with `playwright` and screenshot / read the console.
- **Process a PDF:** `markitdown file.pdf` then ask.

## Smoke tests

```bash
claude mcp list | grep -E 'fetch|playwright'   # both should say Connected
crwl https://example.com -o markdown           # prints markdown
markitdown --help                              # prints usage
```

## Cost

Zero. No API keys, no accounts, no rate limits beyond what the target site enforces. Everything runs on your machine.
