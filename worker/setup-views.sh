#!/usr/bin/env bash
#
# One-time setup for the footer view counter.
#
#   ./setup-views.sh 13975
#
# The argument is the lifetime view total from Google Analytics:
#   GA → Reports → Engagement → Pages and screens
#      → date range "All time" (or 1 Jan 2022 → today)
#      → the Views column total on the summary row.
#
# The counter then starts from that figure instead of from zero.
#
# Requires wrangler signed in to the Cloudflare account that owns the
# portfolio-rag Worker:  npx wrangler login
#
set -euo pipefail
cd "$(dirname "$0")"

SEED="${1:-}"
case "$SEED" in
  '' | *[!0-9]*)
    echo "usage: $(basename "$0") <GA lifetime view total, digits only>" >&2
    exit 1
    ;;
esac

WRANGLER="${WRANGLER:-npx wrangler}"
PLACEHOLDER='PASTE_NAMESPACE_ID_HERE'

# 1. namespace -------------------------------------------------------------
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

# 2. seed ------------------------------------------------------------------
echo "==> seeding the lifetime total to $SEED"
$WRANGLER kv key put --binding=VIEWS total "$SEED" --remote

# 3. deploy ---------------------------------------------------------------
echo "==> deploying"
$WRANGLER deploy

cat <<'DONE'

Done. Check it:
  curl -s https://portfolio-rag.akshitrampershad.workers.dev/views
  -> {"total":<seed>,"today":0}

Then commit the namespace id so the next deploy keeps it:
  git add worker/wrangler.toml && git commit -m "Wire the view counter to its KV namespace"
DONE
