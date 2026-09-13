;;; plugin/editing/completion/corfu.el -*- lexical-binding: t; -*-

;; `corfu-preview-current' defaults (Doom's own choice) to 'insert, which
;; means: once a candidate is previewed, typing PAST it (anything that
;; isn't a completion command) auto-inserts that preview first before
;; processing the keypress - i.e. it can silently commit a candidate you
;; never explicitly accepted, just by continuing to type. This barely
;; came up before, since Doom's default `corfu-preselect' ('prompt) means
;; nothing is preselected/previewed most of the time - but tabby's own
;; suggestion is now ALWAYS force-preselected (see
;; plugin/ai/tabby/config.el's `+tabby-open-corfu-on-suggestion'), so this
;; quirk started firing constantly: keep typing past tabby's suggestion
;; and it gets accepted without ever pressing anything. `t' instead of
;; 'insert keeps the exact same ghost-text preview, just without the
;; silent auto-commit - accepting a candidate now always requires an
;; explicit `RET'/`TAB' (`corfu-insert'/`corfu-complete').
(after! corfu
  (setq corfu-preview-current t)
  ;; Doom's stock corfu module sets this to 'prompt (nothing preselected -
  ;; the popup shows candidates but selection starts on the empty prompt
  ;; line, requiring an explicit TAB/down before RET does anything).
  ;; 'first always preselects the first candidate instead, matching
  ;; standard company-mode-style completion UX.
  (setq corfu-preselect 'first))

;; corfu.el defines faces for the popup itself (`corfu-default',
;; `corfu-current', etc.) but none for the ghost-text PREVIEW overlay -
;; `corfu--preview-current' builds it with `(substring-no-properties
;; (nth corfu--index corfu--candidates))', which strips every text
;; property, face included. It just inherits whatever face is already at
;; that buffer position - normal typed-text face - making the preview
;; visually identical to real text. Advising the function to reapply a
;; dedicated face after it builds the overlay is the only lever available
;; here, since there's no hook/face variable corfu itself exposes for
;; this. `shadow' is Emacs's own standard built-in face for "present but
;; de-emphasized" text - the same category of thing this preview actually
;; is.
(defface +corfu-preview-face
  '((t :inherit shadow))
  "Face for corfu's ghost-text preview overlay, distinct from real text.")

(defun +corfu-preview-add-face (&rest _)
  (when (overlayp corfu--preview-ov)
    (dolist (prop '(after-string display))
      (when-let* ((val (overlay-get corfu--preview-ov prop))
                  ((stringp val)))
        (overlay-put corfu--preview-ov prop
                     (propertize val 'face '+corfu-preview-face))))))

(after! corfu
  (advice-add #'corfu--preview-current :after #'+corfu-preview-add-face))

;; corfu-history: sorts candidates by past acceptance frequency/recency
;; (an MRU boost applied inside `corfu--sort-function''s resolution, on top
;; of whatever a capf's own `display-sort-function' says - see
;; plugin/ai/tabby/config.el's own sort-function fight this session for why
;; that resolution order matters). Doom's stock corfu module already
;; enables this - kept here too, explicitly, since this file is meant to
;; be the one place that owns "which corfu extensions are on."
;; `savehist' persistence is also already wired by Doom's own module.
(use-package! corfu-history
  :hook (corfu-mode . corfu-history-mode))

;; corfu-popupinfo: a side popup showing the selected candidate's
;; documentation or source location - Doom's stock module already enables
;; this too, kept explicit here for the same reason.
;;
;; Initial delay set to 0 - opens on the currently selected candidate
;; immediately, no wait. corfu-popupinfo.el's own docstring explicitly
;; warns against this ("not recommended... will create high load for
;; Emacs. Retrieving the documentation from the backend is usually
;; expensive") since it means EVERY selection change fires a fresh
;; documentation fetch right away, no debouncing - a deliberate tradeoff
;; for immediacy over that cost. Update delay (second number, applied on
;; SUBSEQUENT selection changes while the popup is already open) kept at
;; 1.0s so rapidly cycling `corfu-next'/`corfu-previous' doesn't refetch
;; per keystroke.
(use-package! corfu-popupinfo
  :hook (corfu-mode . corfu-popupinfo-mode)
  :config
  (setq corfu-popupinfo-delay '(0.25 . 0.5))
  ;; No built-in command does this - `corfu-popupinfo--get-documentation'
  ;; is the same (private but stable) helper `corfu-popupinfo-documentation'
  ;; itself calls to fetch the doc string; this just routes that string to
  ;; `message' (the echo area/minibuffer line) instead of opening the
  ;; popup window, for a one-line answer that doesn't cover other
  ;; candidates the way the popup does.
  (defun +corfu-popupinfo-echo ()
    "Show the selected candidate's documentation in the echo area,
instead of `corfu-popupinfo''s side popup."
    (interactive)
    (if (< corfu--index 0)
        (user-error "No candidate selected")
      (let ((cand (nth corfu--index corfu--candidates)))
        (if-let* ((doc (corfu-popupinfo--get-documentation cand)))
            (message "%s" doc)
          (user-error "No documentation available for `%s'"
                      (substring-no-properties cand))))))
  (keymap-set corfu-map "M-e" #'+corfu-popupinfo-echo))

;; corfu-info: on-demand documentation/location in a real, persistent,
;; scrollable buffer (not a transient popup or an echo-area message that
;; disappears on the next command) - for actually reading long docs, not
;; just glancing at them. Not redundant with popupinfo/echo above: those
;; are automatic (triggered on selection change, per their own delay);
;; this is manual-only. `M-h'/`M-g' are corfu.el core's OWN default
;; bindings for these two commands (see `corfu-map' in corfu.el itself),
;; already active via autoload the moment corfu-info.el's commands are
;; first invoked - this `require' just makes that explicit/eager instead
;; of relying on the autoload firing silently on first use.
(after! corfu
  (require 'corfu-info))
