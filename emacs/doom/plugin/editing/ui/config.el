;;; plugin/editing/ui/config.el -*- lexical-binding: t; -*-

;; Doom's stock `:ui treemacs' module explicitly turns this off
;; (`(treemacs-follow-mode -1)' in its own config.el) - re-enable it so the
;; treemacs sidebar tracks whatever buffer you switch to and highlights its
;; file, instead of staying frozen on whatever was selected last.
(after! treemacs
  (treemacs-follow-mode 1))
