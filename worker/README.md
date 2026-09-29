# RAG chatbot — generation layer (Cloudflare Worker)

The chatbot on the portfolio site does retrieval (BM25 over `rag-corpus.json`)
entirely in the browser. This Worker is the one piece that has to run
server-side: it takes the question + retrieved passages and asks Groq to
turn them into one fluent answer, because the Groq API key can never be
shipped to client-side JS.

Cost: Cloudflare Workers free plan (100,000 requests/day) + Groq's free
tier. $0 for the traffic a personal portfolio site gets.

## Option A — Cloudflare dashboard only (no install required)

1. Sign up / log in at [dash.cloudflare.com](https://dash.cloudflare.com) (free).
2. **Workers & Pages → Create → Create Worker.** Give it any name (e.g. `portfolio-rag`), click **Deploy** to scaffold it.
3. Click **Edit code** and replace the entire contents with `rag-worker.js` from this folder. Click **Deploy**.
4. Go to the Worker's **Settings → Variables and Secrets → Add**. Name: `GROQ_API_KEY`, type **Secret**, value: your Groq API key. Save.
5. Copy the Worker's URL (shown at the top, looks like `https://portfolio-rag.<your-subdomain>.workers.dev`).
6. Send me that URL — I'll wire it into `index.html` as `RAG_WORKER_URL` and redeploy the site.

## Option B — Wrangler CLI

```bash
npm install -g wrangler
cd worker
wrangler login
wrangler deploy
wrangler secret put GROQ_API_KEY   # paste the key when prompted
```

`wrangler deploy` prints the Worker's URL — send it to me the same as step 6 above.

## Footer view counter

The same Worker serves `GET /views`, which backs the visitor count in the site
footer. It needs a KV namespace; `setup-views.sh` creates it, seeds it and
deploys in one go:

```bash
cd worker
npx wrangler login
./setup-views.sh 1591
git add wrangler.toml && git commit -m "Wire the view counter to its KV namespace"
```

1591 is the lifetime Views total for the property from Google Analytics
(**Reports → Engagement → Pages and screens**, 1 Jan 2022 – 29 Sept 2026,
Views on the summary row) — the whole site, including the old multi-page
layout whose paths the single page replaced. Seeding is what stops the
counter starting again from zero. To re-seed later, just run the script
again with a new figure; it reuses the existing namespace.

Note the two figures measure slightly different things: the seed is GA
*views*, while everything counted from here on is one browser per day. The
counter therefore grows more slowly than GA will, by design — it is a
visitor count, not a request count.

The page counts one browser per day, so KV writes track unique visits rather
than requests and stay well inside the free tier (1,000 writes/day). Until the
namespace exists `/views` returns 503 and the footer just omits the counter —
nothing on the page breaks.

Check it any time with:

```bash
curl -s https://portfolio-rag.akshitrampershad.workers.dev/views
```

## Notes

- The Worker only accepts requests from `https://akshitrampershad.github.io` (see `ALLOWED_ORIGINS` in `rag-worker.js`) — update that if the site ever moves to a custom domain.
- If the Worker is ever unreachable or misconfigured, the chatbot falls back automatically to showing the retrieved passage directly (no generated summary, but never broken).
- Nothing here requires a paid Cloudflare or Groq plan.
