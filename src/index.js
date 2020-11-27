import { getAssetFromKV } from "@cloudflare/kv-asset-handler"

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event))
})

/**
 * Respond with hello worker text
 * @param {Request} request
 */
async function handleRequest(event) {
  const url = new URL(event.request.url);
  const path = url.pathname;

  if (path == "/surferhearts/") {
    try {
      return await getAssetFromKV(event, {
        mapRequestToAsset: req => new Request(`${new URL(req.url).origin}/index.html`, req)
      });
    } catch (e) { }
  } // if

  try {
    return await getAssetFromKV(event);
  } catch (e) {
    let not_found = await getAssetFromKV(event, {
      mapRequestToAsset: req => new Request(`${new URL(req.url).origin}/404.html`, req)
    });
    return(new Response(not_found.body, { ...not_found, status: 404 }));
  } // try catch

  let x = "<html><head><title>Come back in a few days...</title></head><body>This page is not ready.</body></html>";
  return new Response(x, {
    headers: { 'content-type': 'text/plain' },
    status: 404,
    status_text: "not found"
  })
} // function
