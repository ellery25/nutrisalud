# NutriSalud — Landing Page

A fully self-contained static landing page (`index.html`). No build step, no dependencies — all CSS and JS are inline. The only external resource is the optional Google Fonts (Inter) stylesheet; the page degrades gracefully to system fonts offline.

## Deploy

### GitHub Pages
```bash
git add landing/ && git commit -m "Add landing page" && git push
# Then: repo Settings → Pages → Source: main branch, /landing folder (or move index.html to /docs)
```
Or publish the folder directly with the `gh` CLI on a `gh-pages` branch:
```bash
git subtree push --prefix landing origin gh-pages
```

### Netlify
```bash
npm i -g netlify-cli
netlify deploy --dir=landing --prod
```
(Or drag-and-drop the `landing/` folder at https://app.netlify.com/drop.)

### Vercel
```bash
npm i -g vercel
vercel landing --prod
```

### Cloudflare Pages
```bash
npm i -g wrangler
wrangler pages deploy landing --project-name=nutrisalud
```

## Replacing with a real web app later

- **Flutter Web:** run `flutter build web` in the app repo and deploy `build/web/` to the same host/path that currently serves `landing/`. Keep the same domain so SEO carries over; you can keep this page at `/landing` or `/about` as a marketing page.
- **Next.js:** scaffold with `npx create-next-app`, port the sections of `index.html` into components (each `<section>` maps cleanly to one component), move the inline CSS into a global stylesheet or CSS modules, then deploy to Vercel. Keep the `<head>` meta/JSON-LD block — it lives in `app/layout.tsx` / `next/head`.

## Where to update things

- **Store links:** in `index.html`, find the `#download` section — replace each `.store-badge` `href="#download"` with the real App Store / Google Play URLs, remove `aria-disabled="true"` and the `<span class="soon">Coming soon</span>` badges, and delete the small "Coming soon" click-prevention block at the bottom of the inline `<script>`.
- **Canonical / OG URLs:** update `https://nutrisalud.app/` in the `<link rel="canonical">`, Open Graph and JSON-LD tags once the real domain is live.
- **Contact email:** `hello@nutrisalud.app` appears in the `#contact` section (mailto link).
- **GitHub link:** `https://github.com/ellery25/nutrisalud` appears in the contact and download sections.
