;;; early-init.el -*- lexical-binding: t; -*-

;; Pre-load Evil overrides — must run before Doom's core loads Evil.
(setq evil-want-keybinding nil)      ;; no leftover Emacs keys in special buffers
(setq evil-want-C-u-scroll t)        ;; C-u scrolls up (Doom default, explicit here)
(setq evil-want-C-d-scroll t)        ;; C-d scrolls down
(setq evil-want-C-i-jump t)          ;; C-i jumps forward
(setq evil-want-C-w-delete t)        ;; C-w deletes word (Doom defaults nil)
(setq evil-disable-insert-state-bindings t) ;; no Emacs chords in Insert state
