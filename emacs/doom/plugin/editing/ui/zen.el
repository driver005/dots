;;; plugin/editing/ui/zen.el -*- lexical-binding: t; -*-

;; `:ui zen +focus' normally auto-activates `focus-mode' every time zen-mode
;; (writeroom-mode, `SPC t z') is toggled on - detach that, so dimming is its
;; own independent toggle instead of bundled into zen-mode, off by default.
(after! writeroom-mode
  (remove-hook 'writeroom-local-effects #'focus-mode))

(map! :leader
      (:prefix-map ("t" . "toggle")
       :desc "Dim blocks" "n" #'focus-mode))
