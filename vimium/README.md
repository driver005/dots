# Vimium

[Vimium](https://vimium.github.io/) is a browser extension for keyboard-driven
navigation (Chrome/Firefox). It's not something a dotfiles script can install -
extensions require a manual install from the Chrome Web Store / Firefox
Add-ons page, there's no CLI for that.

What *is* automatable: Vimium's settings. `vimium.json` here is a settings
export (from 2kabhishek's dots2k), importable via Vimium's own options page.

## Setup

1. Install the Vimium extension manually from your browser's extension store.
2. Open Vimium's options page (click its toolbar icon → Options, or visit its
   `options.html`).
3. Scroll to "Import/Export Options" → Import → paste/select `vimium.json`.

## What it changes from Vimium's defaults

- `H`/`L` = previous/next tab (not scroll left/right); `J`/`K` = browser
  back/forward history.
- `gh` = new tab, `gd` = download link under cursor, `go` = open link hint in
  new foreground tab.
- `t` = omnibar search in a new tab; `pp`/`pP` = open copied URL in
  current/new tab.
- `qH`/`qL`/`qo`/`qd` = close tabs to the left/right/others/current.
- `scrollStepSize` doubled to 120 (from 60).
- Custom Vomnibar search-engine keywords: `gg:` Google, `gh:` GitHub search,
  `yt:` YouTube, `so:` Stack Overflow, `wk:` Wikipedia, and more - see the
  `searchEngines` key in `vimium.json` for the full list.
- No site exclusions - Vimium is active everywhere.
