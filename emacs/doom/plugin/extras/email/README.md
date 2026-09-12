# `:email` — enabled modules

`mu4e`, `wanderlust` are commented out — `notmuch` is this config's pick (see the earlier discussion of why: tag-based search-first client, no folders, scales better to large mailboxes than mu4e/wanderlust's folder model).

## `notmuch`
Tag-based, search-first email client (see the earlier explanation of how notmuch's Xapian-indexed, folder-less design works).

Flags in use: none. Other flags available: `+afew` (auto-tagging incoming mail via the `afew` tool), `+org` (`org-mime` integration for composing HTML emails in org-mode).

Requires:
- **Mail sync**: one of `gmailieer`, `mbsync` (isync), or `offlineimap` — downloads mail into a local Maildir. `install-requirements.sh` installs `notmuch` + `isync` (the Arch-recommended default per the Arch Wiki). Writing the actual `~/.mbsyncrc` account config (IMAP host, auth) is **not** automated — that's credential-specific and needs to be done by hand.
- **notmuch itself** — indexes/tags whatever mail sync already downloaded. Installed by `install-requirements.sh`.
- Optional: `afew` for automated initial tagging (only relevant with the `+afew` flag, not enabled here).

| Key | Action |
|---|---|
| `<localleader> u` (`+notmuch/update`) | Download, sync, and index email |
| `<localleader> c` (`+notmuch/compose`) | Compose a new email |
| `SPC o m` | Jump straight to notmuch's search page (calls `+notmuch-home-function`) |
