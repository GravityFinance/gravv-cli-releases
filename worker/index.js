/**
 * Cloudflare Worker for get.gravv.xyz
 *
 *   curl -sSL https://get.gravv.xyz | sh
 *
 * Serves install.sh from the gravv-cli-releases repository.
 *
 * Routes:
 *   GET|HEAD /            -> install.sh
 *   GET|HEAD /install.sh  -> install.sh
 *   anything else         -> 404 with usage
 *
 * There is deliberately no mirror to fall back to. The release pipeline also
 * copies install.sh to s3://gravv-cli/install.sh, but that copy is only
 * refreshed when a release is tagged, so a fallback would serve whatever the
 * last release left behind -- piping a stale installer into a user's shell is
 * worse than failing loudly. Add one back only once that copy is known to
 * track this repository.
 */

const INSTALL_SCRIPT_URL =
  "https://raw.githubusercontent.com/GravityFinance/gravv-cli-releases/main/install.sh";

const USAGE = "Usage: curl -sSL https://get.gravv.xyz | sh\n";

export default {
  async fetch(request) {
    const { pathname } = new URL(request.url);

    if (request.method !== "GET" && request.method !== "HEAD") {
      return new Response("Method not allowed. " + USAGE, {
        status: 405,
        headers: { Allow: "GET, HEAD", "Content-Type": "text/plain; charset=utf-8" },
      });
    }

    if (pathname !== "/" && pathname !== "/install.sh") {
      return new Response("Not found. " + USAGE, {
        status: 404,
        headers: { "Content-Type": "text/plain; charset=utf-8" },
      });
    }

    let script;
    try {
      const response = await fetch(INSTALL_SCRIPT_URL, {
        cf: { cacheTtl: 300, cacheEverything: true },
      });
      if (!response.ok) {
        return new Response("Failed to fetch install script", { status: 502 });
      }
      script = await response.text();
    } catch {
      return new Response("Failed to fetch install script", { status: 502 });
    }

    // The response is piped straight into a shell, so a truncated body would
    // execute half an install. main "$@" is the script's last line.
    if (script.length < 256 || !script.includes('main "$@"')) {
      return new Response("Install script looks incomplete", { status: 502 });
    }

    return new Response(request.method === "HEAD" ? null : script, {
      headers: {
        "Content-Type": "text/plain; charset=utf-8",
        "Cache-Control": "public, max-age=300",
        "Content-Length": String(new TextEncoder().encode(script).length),
        "X-Content-Type-Options": "nosniff",
      },
    });
  },
};
