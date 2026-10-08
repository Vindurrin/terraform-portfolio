This is a starter template for [Learn Next.js](https://nextjs.org/learn).

## Project structure

| Path | What it does |
| --- | --- |
| `pages/` | Next.js's file-based router. Every file here becomes a route: `pages/index.js` is `/`, and a file like `pages/about.js` would become `/about`. Each file default-exports a React component that renders the page. |
| `components/` | *Not in this project yet.* The usual home for reusable UI pieces (header, footer, cards) shared across pages. Create it when you need to share markup between pages. |
| `public/` | Static assets served from the site root as-is: `public/favicon.ico` is available at `/favicon.ico`, `public/vercel.svg` at `/vercel.svg`. |
| `styles/` | CSS. `global.css` applies site-wide. `Home.module.css` is a CSS Module, so its class names are scoped to the component that imports it. |
| `next.config.js` | Next.js configuration. `output: 'export'` makes `npm run build` produce a static site in `out/`. |
| `.next/` | Build cache and dev/server build output. Generated, git-ignored. |
| `out/` | The exportable static site produced by `npm run build`. Generated, git-ignored. |

## Scripts

```bash
npm run dev     # local dev server with hot reload
npm run build   # production build; static export is written to out/
```

Because of `output: 'export'`, the app is exported as static HTML, so `npm run start` (`next start`) isn't used. Serve `out/` with any static host, or locally with `npx serve out`.

Requires Node 20.9 or newer (see `engines` in `package.json`).

## Walkthrough video

_Link to be added._
