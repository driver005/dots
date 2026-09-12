;;; plugin/editing/emacs/exec-path.el -*- lexical-binding: t; -*-

;; The Emacs daemon doesn't go through an interactive shell on startup, so
;; it never sees PATH entries added by ~/.bashrc's own guard-past-the-top
;; (e.g. `~/.npm-global/bin', which is exactly how `tabby-agent' went
;; missing - it's really installed and really on PATH in a terminal, just
;; not in the daemon's inherited environment). `doom sync --env' snapshots
;; PATH once at build time, but that goes stale the moment something new
;; gets installed. This instead re-polls the shell for PATH on every real
;; startup, live, from inside Emacs itself - no separate manual step, no
;; shell-alias wrapper needed.
(use-package! exec-path-from-shell
  :when (memq window-system '(mac ns x pgtk))
  :init
  (exec-path-from-shell-initialize))
