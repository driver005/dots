;;; plugin/editing/ui/rainbow.el -*- lexical-binding: t; -*-

;; Deliberately not auto-enabled via hooks - toggles only, nested under
;; Doom's own stock `SPC t' (toggle) leader group.
(use-package! rainbow-delimiters :commands rainbow-delimiters-mode)
(use-package! rainbow-mode :commands rainbow-mode)
(use-package! symbol-overlay :commands symbol-overlay-mode)

(map! :leader
      (:prefix "t"
       :desc "Rainbow delimiters" "R" #'rainbow-delimiters-mode
       :desc "Rainbow hex colors" "h" #'rainbow-mode
       :desc "Symbol overlay"     "o" #'symbol-overlay-mode))
