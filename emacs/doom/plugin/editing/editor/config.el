;;; plugin/editing/editor/config.el -*- lexical-binding: t; -*-

;; Doom's own factory default here is 4 (already half of vanilla Emacs's
;; own default of 8) - halving it again to 2.
;;
;; `c-basic-offset' needs setting explicitly, separately from `tab-width' -
;; confirmed live it does NOT cascade from `tab-width' the way
;; `set-indent-vars!''s docstring suggests it should. The actual cc-mode
;; module (`~/.emacs.doom.d/sources/doom+/modules/lang/cc/config.el') does
;; `(setq c-basic-offset tab-width ...)' inside `(use-package! cc-mode
;; :config ...)' - a ONE-TIME snapshot taken when the `cc-mode' package
;; first loads, not a per-buffer hook. Doom's own module configs (that
;; snapshot included) all run during Doom's core init, strictly BEFORE any
;; of this repo's own `plugin/*.el' files load - so by the time this file
;; runs, `c-basic-offset' has already baked in the OLD `tab-width' value
;; (4) as its default, and changing `tab-width' afterward here doesn't
;; retroactively fix it. New/reactivated c-derived buffers need it set
;; here directly instead.
(setq-default tab-width 2
              standard-indent 2
              evil-shift-width 2
              c-basic-offset 2)

;; gcmh: raises `gc-cons-threshold' way up while idle, drops it back down
;; the moment you start typing again - GC pauses stop landing mid-keystroke
;; without permanently running with a huge threshold (which just delays a
;; GC pause into one enormous one instead of removing it).
(use-package! gcmh
  :hook (doom-first-buffer . gcmh-mode))

(use-package! crux
  :bind (("C-a" . crux-move-beginning-of-line)
         ("C-k" . crux-smart-kill-line)
         ("M-o" . crux-smart-open-line)
         ("C-c d" . crux-duplicate-current-line-or-region)
         ("C-c D" . crux-delete-file-and-buffer)
         ("C-c r" . crux-rename-file-and-buffer)))

(use-package! string-inflection
  :bind ("C-c i" . string-inflection-all-cycle))

(use-package! visual-regexp
  :bind ("C-c q" . vr/query-replace))

(use-package! visual-regexp-steroids
  :after visual-regexp)

(use-package! ialign
  :commands ialign)

;; Jumplist back/forward as raw bracket motions, Doom's own bracket-motion
;; convention (e.g. `:editor rotate-text''s `[r'/`]r') - `C-o'/`C-i' still
;; work too, this is just an extra mnemonic entry point.
(map! :desc "Jump backward" :n "[j" #'evil-jump-backward
      :desc "Jump forward"  :n "]j" #'evil-jump-forward)

;; Paste + reindent, same bracket-motion convention as `[j'/`]j' above.
;; `evil-paste-before'/-after' set the `['/`]' markers to the pasted
;; region's bounds - `evil-indent' on those is what does the reindent.
(defun +evil-paste-before-and-indent ()
  "Paste before point, then reindent the pasted text."
  (interactive)
  (evil-paste-before 1)
  (evil-indent (evil-get-marker ?\[) (evil-get-marker ?\])))

(defun +evil-paste-after-and-indent ()
  "Paste after point, then reindent the pasted text."
  (interactive)
  (evil-paste-after 1)
  (evil-indent (evil-get-marker ?\[) (evil-get-marker ?\])))

(map! :desc "Paste before + indent" :n "[p" #'+evil-paste-before-and-indent
      :desc "Paste after + indent"  :n "]p" #'+evil-paste-after-and-indent)

;; Rebind the near-universal "Ctrl-S saves" convention every other editor
;; uses - stock Emacs binds bare C-s to `isearch-forward' instead (save is
;; the two-chord `C-x C-s'). Raw incremental search isn't lost: evil's `/'
;; and `SPC s s' (consult-line, via vertico) already cover buffer search.
(global-set-key (kbd "C-s") #'save-buffer)

;; In insert state specifically, C-s also drops back to normal state -
;; matches the usual "save and get out of the way" reflex. Bound on
;; `evil-insert-state-map' so it overrides the global one above only while
;; actually inserting; every other state keeps plain `save-buffer'.
(defun +save-buffer-and-normal-state ()
  "Save the buffer, then return to evil normal state."
  (interactive)
  (save-buffer)
  (evil-normal-state))

(map! :i "C-s" #'+save-buffer-and-normal-state)

;; evil-snipe (s/S/f/t/F/T) has real highlighting enabled by default
;; (evil-snipe-enable-highlight/-incremental-highlight are both t out of
;; the box), but `evil-snipe-matches-face' - the face for every candidate
;; OTHER than the first - has no :background set under this theme, only a
;; foreground tweak, so secondary matches barely register visually; only
;; the first match's own face (which does have a real background) is
;; obviously visible. Give it `lazy-highlight''s background - Emacs's own
;; face for "other search matches" pairs correctly with `first-match'
;; already inheriting `isearch' ("current match").
(after! evil-snipe
  (set-face-background 'evil-snipe-matches-face
                        (face-attribute 'lazy-highlight :background nil t)))

;; `C-g' already exits evil-multiedit (bound directly in its own mode-map -
;; see evil-multiedit.el). Plain `<escape>' is only supposed to reach the
;; same abort via `evil-multiedit-abort' being :before advice on
;; `evil-force-normal-state' - but something upstream can intercept ESC
;; first depending on major mode, leaving the iedit highlight stuck. Bind
;; it directly here too, same guaranteed path as `C-g'.
(after! evil-multiedit
  (map! :map evil-multiedit-mode-map
        :n "<escape>" #'evil-multiedit-abort))
