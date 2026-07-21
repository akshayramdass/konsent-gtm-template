# konsent for Google Tag Manager

A certified **GTM Community Template** for konsent. konsent is a hosted
consent-management platform (a CookieYes or Cookiebot alternative). Instead of
pasting the loader as a Custom HTML tag, a GTM user adds konsent as a proper tag,
picks it from the Gallery, types their Site Key, and fires it on Consent
Initialization. The tag injects the konsent loader, which then runs the consent
banner and blocks tracking until a visitor consents.

This is a **distributed artifact**, not part of the konsent server image. It lives
in its own public GitHub repo that you (the konsent owner) submit to the GTM
Community Template Gallery once. After that, every GTM user adds it from the
Gallery with no code.

## Files

- `template.tpl`: the GTM custom template. Metadata, the two fields (Site Key and
  API base), the sandboxed JS that injects the loader with the key as a query
  param, the `inject_script` permission, and tests.
- `metadata.yaml`: the Gallery metadata (homepage and released versions). Goes at
  the repo root.
- `LICENSE`: Apache-2.0. The Gallery requires a license file at the repo root.

## How a GTM user installs it (after it is in the Gallery)

1. In GTM: **Tags → New → Tag Configuration → Discover more tag types**.
2. Search for **konsent** and add it.
3. Paste the **Site Key** from the konsent dashboard (looks like `ck_live_...`).
   Leave the API base URL as the default unless self-hosting.
4. Set the trigger to **Consent Initialization - All Pages** so konsent loads
   before other tags. Save and publish the container.

That is the whole install. Nothing about consent is configured in GTM; it all
lives in the konsent dashboard. The loader still owns the banner, category
blocking, consent proof, geo-targeting, and multi-language text.

### A "Cookie settings" link

The loader exposes `window.konsent.showPreferences()`, so any button can reopen
the consent dialog:

```html
<button type="button"
  onclick="if(window.konsent&&window.konsent.showPreferences){window.konsent.showPreferences();}return false;">
  Cookie settings
</button>
```

## Submitting it to the Gallery (owner only)

Only the konsent owner can do this; it needs a GitHub account and involves a
Google review. Steps:

1. **Create a new public GitHub repo** (for example `konsent-gtm-template`). Do
   not nest it under a larger repo; the Gallery reads the template files from the
   repo **root**.
2. **Copy these files to the repo root**: `template.tpl`, `metadata.yaml`, and
   `LICENSE`. (Copy them out of this `integrations/gtm/` folder.)
3. **Commit and push.** Then fill `metadata.yaml`'s `sha` with the full commit
   hash of that release (`git rev-parse HEAD`), commit again, and push.
4. **Sign in to the Gallery** at
   https://tagmanager.google.com/gallery and choose **Add a template** (or open
   the template in GTM's template editor and use **Community Gallery → Add to
   Gallery**). Authorize the GitHub repo when prompted.
5. **Confirm the details** (icon, description, homepage) and submit. Google
   reviews the template before it appears publicly. Reviews can take a few days
   and may come back with change requests.
6. **Releasing updates:** bump `version` in `template.tpl`'s `___INFO___`, push a
   new commit, and add a new entry under `versions:` in `metadata.yaml` with the
   new commit `sha` and change notes.

### What only the owner can do

- Owning the public GitHub repo and the Gallery listing.
- Passing Google's review and responding to any change requests.
- Adding a template icon (the Gallery listing needs one; add it in the editor).
- Choosing the brand name shown in the Gallery.

Everything a merchant needs (their Site Key) they enter themselves in GTM.

## How the key reaches the loader

A sandboxed GTM template can inject a script URL but cannot set `data-*`
attributes on it, so the template passes the Site Key and API base as query params
(`/loader/konsent.js?key=...&api=...`). The konsent loader reads its config from,
in order: `data-*` attributes, then those query params, then a `window.__konsent`
global, and it can also derive the API base from its own script URL. So the same
loader works from a plain `<script>` tag, this GTM template, or any other injector.

## Notes

- konsent is hosted. This template only injects the loader; it stores no consent
  data in GTM and does no blocking itself. Blocking runs in the browser, in the
  loader, before other tags fire, which is why the Consent Initialization trigger
  matters.
- Self-hosting: change the **API base URL** field, and edit the `inject_script`
  permission in `template.tpl` to allow your own host (it currently allows
  `https://konsent.sigilandclover.com/*`).
- The paste-as-Custom-HTML path still works and needs no Gallery submission; this
  template is the polished, no-code alternative for GTM users.
