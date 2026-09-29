#!/usr/bin/env bash
#
# One-time setup for the footer view counter.
#
#   ./setup-views.sh
#
# Creates the VIEWS KV namespace, writes its id into wrangler.toml, and
# deploys. There is nothing to seed: the pre-existing Google Analytics
# total lives in rag-worker.js as VIEWS_BASELINE, and KV only holds what
# the counter has tallied since.
#
# Requires wrangler signed in to the Cloudflare account that owns the
# portfolio-rag Worker:  npx wrangler login
#
# Prefer the dashboard? See "Footer view counter" in README.md.
#
set -euo pipefail
cd "$(dirname "$0")"

WRANGLER="${WRANGLER:-npx wrangler}"
PLACEHOLDER='PASTE_NAMESPACE_ID_HERE'

if grep -q "$PLACEHOLDER" wrangler.toml; then
  echo "==> creating KV namespace VIEWS"
  $WRANGLER kv namespace create VIEWS >/dev/null

  echo "==> looking up its id"
  ID=$($WRANGLER kv namespace list | node -e '
    let s = "";
    process.stdin.on("data", d => s += d).on("end", () => {
      const ns = JSON.parse(s.slice(s.indexOf("[")));
      const hit = ns.filter(n => /(^|[-_])VIEWS$/.test(n.title)).pop();
      if (!hit) { console.error("no VIEWS namespace found"); process.exit(1); }
      process.stdout.write(hit.id);
    });
  ')
  [ -n "$ID" ] || { echo "could not determine the namespace id" >&2; exit 1; }

  echo "==> writing id $ID into wrangler.toml"
  sed -i.tmp "s/$PLACEHOLDER/$ID/" wrangler.toml && rm -f wrangler.toml.tmp
else
  echo "==> wrangler.toml already names a namespace, reusing it"
fi

echo "==> deploying"
$WRANGLER deploy

cat <<'DONE'

Done. Check it:
  curl -s https://portfolio-rag.akshitrampershad.workers.dev/views
  -> {"total":1591,"today":0}

Then commit the namespace id so the next deploy keeps it:
  git add worker/wrangler.toml && git commit -m "Wire the view counter to its KV namespace"
DONE
