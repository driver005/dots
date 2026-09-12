;;; plugin/editing/ui/theme.el -*- lexical-binding: t; -*-

(setq doom-theme 'doom-one)

;; `t' = absolute line numbers, `relative' = relative, `nil' = disabled.
(setq display-line-numbers-type t)

;; The bar with the window title text + close/minimize/maximize buttons is
;; the window manager's own decoration, not Emacs' menu-bar - `undecorated'
;; asks the WM to skip drawing it for Emacs frames. Must be in
;; default-frame-alist (applies to frames as they're created), setting the
;; frame parameter directly on an already-live frame often doesn't
;; re-decorate it without a restart anyway.
(add-to-list 'default-frame-alist '(undecorated . t))

;; Always start fullscreen. `fullboth' = fullscreen (no WM decorations at
;; all, takes the whole screen); use `maximized' instead if you want the WM
;; to still show its own borders/taskbar around a maximized window.
(add-to-list 'default-frame-alist '(fullscreen . fullboth))
