;;; plugin/editing/editor/which-key-leader.el -*- lexical-binding: t; -*-

;; Same mechanism as which-key.el, but these are `doom-leader-map' keys
;; with no `:desc' at all (plain Emacs core bindings Doom never wraps -
;; the help/window groups reuse `help-map'/`evil-window-map' directly) -
;; `which-key-desc-overrides.el' only handles leader bindings that
;; already HAVE a (too-long) :desc; these have none, so a key-based
;; replacement is simpler than re-declaring the whole map! path.
;; NOTE: no "SPC " prefix - which-key resolves these relative to
;; `doom-leader-map' itself (you're already "inside" it once SPC is
;; pressed). An earlier attempt at these very entries used "SPC h ..."
;; and silently never matched anything.
;;
;; Matching is still global (see which-key.el's banner comment) - these
;; are lower collision-risk in practice since they're multi-key Emacs-core
;; paths under `h'/`w', not single evil motion letters, but grep before
;; adding here too.
(after! which-key
  (which-key-add-key-based-replacements
   "w m v" "maximize vertically" "w m s" "maximize horizontally"
   "h C-s" "search help topics" "h K" "key node"
   "h L" "language environment" "h b i" "minor mode keymap"
   "h M" "active mode" "h C-l" "language environment"))
