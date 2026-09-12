;;; plugin/editing/emacs/notifications.el -*- lexical-binding: t; -*-

;; ednc: manage desktop (D-Bus) notifications from inside Emacs instead of
;; the system tray - shows up in the mode line, notifications become
;; buffers you can act on.
(use-package! ednc
  :hook (after-init . ednc-mode))
