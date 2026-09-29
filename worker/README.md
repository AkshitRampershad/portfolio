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
footer. It needs one KV namespace bound as `VIEWS`. Nothing needs seeding: the
1,591 views the site had before the counter existed (Google Analytics, 1 Jan
2022 - 29 Sept 2026, all five paths of the old multi-page layout) are
`VIEWS_BASELINE` in `rag-worker.js`, and KV holds only what the counter has
tallied since.

### Option A - Cloudflare dashboard

1. **Storage & Databases -> KV -> Create instance.** Name it `VIEWS`. (On older
   dashboards KV sits under Workers & Pages instead.)
2. **Workers & Pages -> portfolio-rag -> Settings -> Bindings -> Add -> KV
   namespace.** Variable name `VIEWS` (exactly, in capitals), namespace: the one
   just created. Save.
3. **Edit code**, replace the contents with `rag-worker.js` from this folder,
   **Deploy**. This step matters: a Worker deployed before the counter existed
   has no `/views` route, so the footer stays blank without it.

### Option B - Wrangler CLI

```bash
cd worker
npx wrangler login
./setup-views.sh
git add wrangler.toml && git commit -m "Wire the view counter to its KV namespace"
```

### Either way, verify

```bash
curl -s https://portfolio-rag.akshitrampershad.workers.dev/views
# {"total":1591,"today":0}
```

`{}` with a 503 means the binding is missing or misnamed; a 404 means the
deployed code predates the `/views` route.

### Notes on the numbers

The baseline is GA *views*; everything counted from here is one browser per
day, so the figure climbs more slowly than GA does. That is deliberate - it is
a visitor count, and it keeps KV writes far inside the free tier (1,000/day).

Only requests carrying an allowed `Origin` can increment the count, so the
figure cannot be inflated from outside the site. Reads are open to anyone.

To change the baseline later, edit `VIEWS_BASELINE` and redeploy; the tally in
KV is untouched. Deleting and recreating the namespace loses only the tally.

## Notes

- The Worker only accepts requests from `https://akshitrampershad.github.io` (see `ALLOWED_ORIGINS` in `rag-worker.js`) — update that if the site ever moves to a custom domain.
- If the Worker is ever unreachable or misconfigured, the chatbot falls back automatically to showing the retrieved passage directly (no generated summary, but never broken).
- Nothing here requires a paid Cloudflare or Groq plan.
