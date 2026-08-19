# Firecrawl & the OSS Scraping Landscape

Research date: 2026-08-19. Every non-obvious claim cited. `[unverified]` = could not confirm.

## 1. What it is

Firecrawl is a hosted web-data API that turns URLs into LLM-ready markdown/JSON, absorbing proxies, anti-bot, JS rendering and dynamic content so you don't run browser infrastructure. Source is on GitHub under AGPL-3.0 and self-hostable, but the managed API is the product. ([docs](https://docs.firecrawl.dev/introduction), [repo](https://github.com/firecrawl/firecrawl))

## 2. Features

- **Endpoints**: `scrape` (one URL), `crawl` (recursive site), `map` (URL discovery, no content), `search` (web query + full page content), `extract` (structured data), `parse` (local PDF/DOCX/XLSX/HTML → markdown/JSON), `interact` (browser sandbox: clicks, form fills). ([docs](https://docs.firecrawl.dev/introduction))
- **Output formats**: markdown, HTML, structured JSON, screenshots, metadata. ([docs](https://docs.firecrawl.dev/introduction))
- **JS rendering + anti-bot**: handled server-side — "Proxies, anti-bot, JavaScript rendering, and dynamic content". ([docs](https://docs.firecrawl.dev/introduction))
- **Structured extraction**: schema-based JSON from `scrape`/`extract`; FIRE-1 agent autonomously navigates sites without hand-tuned selectors. ([comparison](https://crawl4ai.dev/crawl4ai-vs-firecrawl))
- **Batching + webhooks**: batch scrape across URL lists; webhooks for async job events. ([docs](https://docs.firecrawl.dev/introduction))
- **SDKs**: Python, Node.js, CLI, REST. ([docs](https://docs.firecrawl.dev/introduction))
- **Official MCP server**: hosted keyless at `https://mcp.firecrawl.dev/v2/mcp`; keyless exposes Search/Scrape/Parse with usage limits, API key/OAuth unlocks account tools (crawl, extract, monitors, research). ([docs](https://docs.firecrawl.dev/introduction))
- **Self-hosting**: Docker Compose, AGPL-3.0. **Catch — see §4.** ([SELF_HOST.md](https://github.com/firecrawl/firecrawl/blob/main/SELF_HOST.md))
- **Monitoring**: scheduled re-checks of pages for changes (`monitor_*` tools), billed 1 credit/page.

## 3. How it works

- Request hits the API → job queued (Postgres/Redis/RabbitMQ in the self-host stack).
- Render: headless browser (Playwright in self-host; managed adds proxy rotation + anti-bot engines).
- Clean: strips nav/ads/footers/boilerplate to main content.
- Format: markdown / JSON (schema-driven, LLM-assisted for `extract`) / HTML / screenshot; crawl jobs fan out over discovered links, polled via `/crawl/status` or pushed by webhook.

**Credit model** ([pricing](https://www.firecrawl.dev/pricing)):

| Operation | Cost |
|---|---|
| Scrape / Crawl / Map / Monitor | 1 credit per page |
| Search | 2 credits per 10 results |
| Interact (browser sandbox) | 2 credits per browser minute |

**Plans** ([pricing](https://www.firecrawl.dev/pricing)) — Free $0 / 1,000 credits / 2 concurrent; Hobby $16/mo (yearly) / 5,000; Standard $83/mo / 100,000 / 50 concurrent; Growth $333/mo / 500,000; Scale $599/mo / 1,000,000 / 150 concurrent ($397 per extra 350k credits); Enterprise custom (ZDR, SSO).

**Rate limits, req/min** ([docs](https://docs.firecrawl.dev/rate-limits)):

| Plan | /scrape | /map | /crawl | /search | /agent |
|---|---|---|---|---|---|
| Free | 10 | 10 | 2 | 10 | 2 |
| Hobby | 100 | 100 | 20 | 100 | 20 |
| Standard | 500 | 500 | 100 | 500 | 100 |
| Growth | 5,000 | 5,000 | 1,000 | 5,000 | 1,000 |
| Scale | 10,000 | 10,000 | 2,000 | 10,000 | 2,000 |

Exceeding rate **or** concurrency returns `429`.

## 4. Best at / worst at

**Best at**
- Zero-infra reliability: proxies + anti-bot + JS handled for you; measurably faster than self-run Crawl4AI on JS-heavy sites (240s vs 380s for 100 pages, Jan 2026 test). ([benchmark](https://crawl4ai.dev/crawl4ai-vs-firecrawl))
- Breadth in one API: scrape/crawl/map/search/extract/parse/monitor behind a single key and one MCP server.
- Agent-friendly defaults: clean markdown out of the box, no selector maintenance.

**Worst at**
- **Cost at volume.** Pure per-page credits. Past high volume, infra-only OSS is cheaper. ([comparison](https://use-apify.com/blog/firecrawl-vs-crawl4ai))
- **Self-hosting is not feature parity.** Docker default ships *no auth*, *no persistent volumes* (data lost on restart), and only bundled Playwright + basic fetch — the managed anti-bot/proxy engines require separate setup. You own security, availability, upgrades. ([SELF_HOST.md](https://github.com/firecrawl/firecrawl/blob/main/SELF_HOST.md))
- **AGPL-3.0** — network-use copyleft. Fine internally, a real question if you embed it in a hosted product. ([repo](https://github.com/firecrawl/firecrawl))
- Free tier is a demo: 1,000 credits/mo, 2 concurrent, 2 crawl req/min.

## 5. Competitors

| Tool | OSS? | Free tier | Self-host | MCP server? | Best for | Catch |
|---|---|---|---|---|---|---|
| **Firecrawl** | AGPL-3.0 core | 1,000 credits/mo, 2 concurrent | Yes (degraded) | Official, hosted + npm | All-in-one LLM-ready ingest | Paid past 1k pages; self-host lacks anti-bot/persistence |
| **Crawl4AI** | Apache-2.0, 78.6k★ | Fully free | Yes, first-class | **Built-in** at `/mcp/sse` | Free Firecrawl replacement, high volume | You run/tune it; slower on JS-heavy sites |
| **ScrapeGraphAI** | MIT, 29.7k★ | Free lib | Yes | Third-party | LLM-graph scraping w/ your own model | **Needs an LLM API key** — not free end-to-end |
| **Jina AI Reader** | Service | Keyless ~20 RPM; key = 10M free tokens | No | Third-party | One-liner URL→markdown, zero setup | Freemium; $0.02/1M output tokens after free tokens |
| **Apify** | Platform (many actors OSS) | $5 platform credits/mo, no rollover | No | Official (`apify-mcp-server`, MIT) | Prebuilt scrapers for named sites | Compute-unit billing, opaque; $5 goes fast |
| **Browserbase / Stagehand** | Stagehand MIT, 24k★; Browserbase closed | Free plan exists; Dev $20/mo, Startup $99/mo | Stagehand yes, Browserbase no | Official | AI-driven browser interaction, auth'd flows | Stagehand needs an LLM key; Browserbase is the paid runtime |
| **Playwright / Puppeteer (DIY)** | Apache-2.0, 94.7k/95.5k★ | Free | Yes | `microsoft/playwright-mcp` (Apache-2.0, 36k★) | Full control, logins, complex JS | You build cleaning, markdown, proxies, retries |
| **Tavily** | Closed | 1,000 credits/mo | No | Official (MIT) | Agent web search w/ snippets | Freemium; 1 credit basic / 2 advanced |
| **Exa** | Closed | 20,000 req/mo + $10/mo credits, no card | No | Official (MIT, 4.9k★) | Semantic/neural search, biggest free tier | Search ≠ crawl; paid past free tier |
| **Serper** | Closed | 2,500 queries **one-time trial** | No | Third-party | Cheap Google SERP, $0.30/1k | Not a recurring free tier |
| **Scrapy** | BSD-3, 63.9k★ | Free | Yes | Third-party only | Large structured crawls at scale | No JS rendering by default; no LLM output; steep |

## 6. Genuinely free & self-hostable

No paid API key required to run. All confirmed via GitHub API on 2026-08-19.

| Repo | License | ★ | Last push | Maintained |
|---|---|---|---|---|
| [unclecode/crawl4ai](https://github.com/unclecode/crawl4ai) | Apache-2.0 | 78,643 | 2026-08-18 | Yes, very active |
| [microsoft/playwright](https://github.com/microsoft/playwright) | Apache-2.0 | 94,713 | 2026-08-19 | Yes |
| [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp) | Apache-2.0 | 36,262 | 2026-08-17 | Yes |
| [puppeteer/puppeteer](https://github.com/puppeteer/puppeteer) | Apache-2.0 | 95,462 | 2026-08-18 | Yes |
| [scrapy/scrapy](https://github.com/scrapy/scrapy) | BSD-3-Clause | 63,947 | 2026-08-19 | Yes |
| [adbar/trafilatura](https://github.com/adbar/trafilatura) | Apache-2.0 | 6,660 | 2026-08-15 | Yes — best-in-class boilerplate stripping |
| [microsoft/markitdown](https://github.com/microsoft/markitdown) | MIT | 174,553 | 2026-07-29 | Yes — any doc → markdown |
| [firecrawl/firecrawl](https://github.com/firecrawl/firecrawl) | AGPL-3.0 | 169,256 | 2026-08-19 | Yes — but see §4 self-host caveats |
| [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) `fetch` | MIT | 89,677 | 2026-08-18 | Yes — reference server, plain URL→markdown |

Needs an LLM key, so **not** free end-to-end: [ScrapeGraphAI](https://github.com/ScrapeGraphAI/Scrapegraph-ai) (MIT, 29.7k★, 2026-07-20), [browserbase/stagehand](https://github.com/browserbase/stagehand) (MIT, 24k★, 2026-08-18).

Third-party Crawl4AI MCP wrappers exist but are unnecessary — Crawl4AI ships MCP natively. Largest, `coleam00/mcp-crawl4ai-rag` (MIT, 2.2k★), last pushed **2025-07-25 — stale**.

## 7. Top picks

1. **Crawl4AI** — Apache-2.0, 78k★, ships its own MCP endpoint; the only drop-in that replaces Firecrawl's core loop at zero marginal cost.
2. **playwright-mcp** — Microsoft-maintained, Apache-2.0; the escape hatch for logins, multi-step flows and anything Crawl4AI's fetch can't reach.
3. **Exa MCP** — 20,000 free requests/month with no card is the most generous discovery layer, and search is the one job neither of the above does well.

**Recommended stack**

| Job | Tool |
|---|---|
| Find the URLs | Exa MCP (free tier) |
| Bulk scrape/crawl → markdown | Crawl4AI (local Docker) |
| Auth'd / interactive / stubborn pages | playwright-mcp |
| Local PDF/DOCX/XLSX → markdown | markitdown (CLI, no server) |
| Occasional one-off, zero setup | already-connected Firecrawl MCP, keyless |

## 8. Wire-up

**Crawl4AI — no API key.**
```bash
docker run -d -p 11235:11235 --name crawl4ai --shm-size=1g unclecode/crawl4ai:latest
claude mcp add --transport sse c4ai http://localhost:11235/mcp/sse
```
Tool schemas at `http://localhost:11235/mcp/schema`. ([docs](https://docs.crawl4ai.com/core/self-hosting/))

**playwright-mcp — no API key.**
```bash
claude mcp add playwright -- npx -y @playwright/mcp@latest
```

**Exa MCP — REQUIRES a free API key** (exa.ai, no card).
```bash
claude mcp add exa -e EXA_API_KEY=your_key -- npx -y exa-mcp-server
```

**markitdown — no server, no key.**
```bash
uvx markitdown path/to/file.pdf > out.md
```

**Firecrawl — already connected in this session, keyless.** Keyless = Search/Scrape/Parse under usage limits. Full toolset needs a key:
```bash
claude mcp add --transport http firecrawl https://mcp.firecrawl.dev/v2/mcp
```

JSON equivalent (`.mcp.json`):
```json
{
  "mcpServers": {
    "c4ai": { "type": "sse", "url": "http://localhost:11235/mcp/sse" },
    "playwright": { "command": "npx", "args": ["-y", "@playwright/mcp@latest"] },
    "exa": { "command": "npx", "args": ["-y", "exa-mcp-server"], "env": { "EXA_API_KEY": "your_key" } }
  }
}
```

## 9. Skill proposal — NOT created, awaiting go-ahead

**Name:** `web-ingest`

**Description line:** Fetch, crawl, and convert web or local documents into clean LLM-ready markdown; routes each request to the cheapest tool that can do the job and escalates only when it fails.

**What it does:** encodes the §7 routing table as a decision ladder — try the free local path first (Crawl4AI for URLs, markitdown for local files), escalate to playwright-mcp only on JS/auth failure, use Exa when the URL isn't known yet, and fall back to Firecrawl's keyless MCP only as last resort. Also standardises output (one markdown file per source with a URL + fetch-date header) and states which tool was used and why, so the cost of each ingest is visible.

Nothing here duplicates `deep-research`, `exa-search`, or `data-scraper-agent` — those pick sources or synthesise; this one is the fetch/convert layer beneath them.

## Sources

- https://docs.firecrawl.dev/introduction
- https://www.firecrawl.dev/pricing
- https://docs.firecrawl.dev/rate-limits
- https://github.com/firecrawl/firecrawl
- https://github.com/firecrawl/firecrawl/blob/main/SELF_HOST.md
- https://docs.crawl4ai.com/core/self-hosting/
- https://crawl4ai.dev/crawl4ai-vs-firecrawl
- https://use-apify.com/blog/firecrawl-vs-crawl4ai
- https://jina.ai/reader/
- https://use-apify.com/docs/what-is-apify/apify-free-plan
- https://github.com/modelcontextprotocol/servers
- https://mcpservers.org/category/web-scraping
