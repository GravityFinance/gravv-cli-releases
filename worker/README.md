# get.gravv.xyz worker

Serves [`install.sh`](../install.sh) so that this works:

```bash
curl -sSL https://get.gravv.xyz | sh
```

## Deploy

```bash
cd worker
npx wrangler deploy
```

`wrangler.toml` claims `get.gravv.xyz` as a custom domain, so Cloudflare creates the DNS record itself once the zone is in the account. The subdomain does not need to exist beforehand.

## Behaviour

- `GET|HEAD /` and `/install.sh` return the script as `text/plain`, cached for five minutes at the edge.
- Anything else returns 404 with the usage line; non-GET/HEAD returns 405.
- The script is read from `raw.githubusercontent.com` on the `main` branch. A response is only served if it looks like a complete script — a truncated body would otherwise be piped straight into a user's shell.
- There is deliberately **no mirror fallback**. The release pipeline also copies `install.sh` to `s3://gravv-cli/install.sh`, but only when a release is tagged, so that copy lags this repository and today still holds a pre-POSIX version. Serving it would pipe a stale installer into a user's shell. Add a fallback back only once that copy is known to track `main`.

## Checking it

```bash
curl -sSL https://get.gravv.xyz | head -20          # should be the script
curl -sSL https://get.gravv.xyz | sh -n             # should parse cleanly
curl -sS -o /dev/null -w '%{http_code}\n' https://get.gravv.xyz/nope   # 404
```
