;;; +perf.el -*- lexical-binding: t; -*-

;; Increase process read size for LSP
(setq read-process-output-max (* 1024 1024 3))

;; Optimize Garbage Collection thresholds
(setq gc-cons-threshold (* 256 1024 1024)
      gcmh-high-cons-threshold (* 512 1024 1024)
      gcmh-low-cons-threshold (* 32 1024 1024)
      gcmh-idle-delay 3)

;; JIT deferral to prevent scroll freezes
(setq jit-lock-defer-time 0.05
      jit-lock-chunk-size 4096)

;; Disable expensive features for large files
(global-so-long-mode 1)

;; Enable Garbage Collector Magic Hack
(use-package! gcmh
  :hook (doom-first-buffer . gcmh-mode))
