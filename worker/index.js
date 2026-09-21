/**
 * Cloudflare Worker for get.gravv.xyz
 *
 *   curl -sSL https://get.gravv.xyz | sh
 *
 * Serves install.sh from the gravv-cli-releases repository. The release
 * pipeline mirrors the same file to S3, so that copy is used as a fallback
 * when raw.githubusercontent.com is unreachable -- an installer URL that
 * fails is worse than a slightly stale one.
 *
 * Routes:
 *   GET|HEAD /            -> install.sh
 *   GET|HEAD /install.sh  -> install.sh
 *   anything else         -> 404 with usage
 */

const SOURCES = [
  "https://raw.githubusercontent.com/GravityFinance/gravv-cli-releases/main/install.sh",
  "https://gravv-cli.s3.us-east-1.amazonaws.com/install.sh",
];

const SCRIPT_PATHS = new Set(["/", "/install.sh"]);

const USAGE = "Usage: curl -sSL https://get.gravv.xyz | sh\n";

/** Fetch the script, trying each source in turn. */
async function fetchScript() {
  let lastStatus = 0;

  for (const source of SOURCES) {
    try {
      const response = await fetch(source, {
        cf: { cacheTtl: 300, cacheEverything: true },
      });
      if (response.ok) {
        const body = await response.text();
        // A truncated or empty body would be executed by the caller's shell,
        // so treat anything that is not a plausible script as a failure.
        if (body.length > 256 && body.includes("main \"$@\"")) {
          return body;
        }
      }
      lastStatus = response.status;
    } catch {
      lastStatus = 502;
    }
  }

  return { error: lastStatus || 502 };
}

export default {
  async fetch(request) {
    const { pathname } = new URL(request.url);

    if (request.method !== "GET" && request.method !== "HEAD") {
      return new Response("Method not allowed. " + USAGE, {
        status: 405,
        headers: { Allow: "GET, HEAD", "Content-Type": "text/plain; charset=utf-8" },
      });
    }

    if (!SCRIPT_PATHS.has(pathname)) {
      return new Response("Not found. " + USAGE, {
        status: 404,
        headers: { "Content-Type": "text/plain; charset=utf-8" },
      });
    }

    const script = await fetchScript();
    if (typeof script !== "string") {
      return new Response(
        "Could not fetch the install script. Try again, or install directly:\n" +
          "  curl -sSL " + SOURCES[0] + " | sh\n",
        { status: 502, headers: { "Content-Type": "text/plain; charset=utf-8" } },
      );
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
