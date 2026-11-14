# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Teaching notes (bibliography, lecture material) for students at notes.rigascg.com. A minimal Jekyll site that copies the look and front-end behaviour of the portfolio
repo (`ksepastremenos/ksepastremenos.github.io`, see its CLAUDE.md), edited with Sveltia CMS (`admin/`), deployed by
`.github/workflows/deploy.yml` (Pages source must be "GitHub Actions" because of the custom plugins). There are
no tests; check changes in a browser, including Firefox (the owner's default browser).

```sh
bundle exec jekyll serve      # http://localhost:4000
```

## Sister site

The `notes` and `blog` repos are built from the same skeleton. `assets/style.css`, `assets/js/*`,
`_layouts/default.html`, `_includes/tile.html` and `_plugins/*` are kept identical between them; a change to one
usually belongs in both. Per-site differences live in `_config.yml` (accent colours, tile palette hue/spread,
collections) and `_data/settings.yml` (interface text, editable in the CMS; there is no localization).

## How it fits together

- Content: _notes/<slug>.md (title, date, type keyword, body, files). Edited through `admin/config.yml`, which must stay in sync with the templates.
- index.html builds both views (by date, by type) at build time; a small inline script switches between them and remembers the choice in localStorage. Tiles always show their title (.grid--labels).
- Tile art: `_plugins/tiles.rb` (`tile_art` filter) turns a page URL into a CSS gradient/pattern, seeded with
  CRC32 of the URL so each entry keeps its look across builds. Colours come from `site.palette` (hue ± spread).
  Hover zoom (`scale(1.2)`) is in `style.css`.
- `_plugins/images.rb`: post-render hook giving local `<img>` in entries their width/height plus lightbox attributes
  (`assets/js/lightbox.js`, loaded on entry pages).
- `style.css` has Jekyll front matter so it can read the accent colours from `_config.yml`.
- Same behaviours as the portfolio: page scrolls inside SimpleBar (structure pre-written in the layout), page fades
  via cross-document view transitions with a script fallback (`js-fade`, for Firefox), and the fade must not be
  disabled for `prefers-reduced-motion` (the owner's OS has animations off).
- Every page carries `<meta name="robots" content="noindex, nofollow">`; don't add a robots.txt disallow (crawlers
  must fetch pages to see the noindex) or a sitemap.
