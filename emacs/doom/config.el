;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Config is split by category/integration under plugin/<category>/*.el
(load! "plugin/editing/emacs/exec-path")
(load! "plugin/editing/ui/theme")
(load! "plugin/editing/emacs/wayland-focus")
(load! "plugin/editing/emacs/filetype-warning")
(load! "plugin/editing/emacs/notifications")
(load! "plugin/editing/editor/config")
(load! "plugin/editing/editor/which-key")
(load! "plugin/editing/editor/which-key-leader")
(load! "plugin/editing/editor/which-key-desc-overrides")
(load! "plugin/editing/completion/corfu")
(load! "plugin/editing/ui/config")
(load! "plugin/editing/ui/rainbow")
(load! "plugin/editing/ui/zen")
(load! "plugin/org/config")
(load! "plugin/org/extras")
(load! "plugin/dev/tools/magit-extras")
(load! "plugin/dev/lang/config")
(load! "plugin/ai/gptel/config")
(load! "plugin/ai/agent/config")
(load! "plugin/ai/tabby/config")
(load! "plugin/ai/tabby/balancer")
(load! "plugin/ai/tabby/menu")
(load! "plugin/ai/tabby/nes")
(load! "plugin/ai/octocode/config")

;; Performance tweaks
;; Increase how much data Emacs reads from background processes (like language servers)
(setq read-process-output-max (* 1024 1024 3)) ;; 3mb

;; Optimize Garbage Collection (reduce lag spikes during heavy usage)
(setq gc-cons-threshold (* 100 1024 1024)       ;; 100mb
      gcmh-high-cons-threshold (* 100 1024 1024)) ;; 100mb for Doom's GC Magic Hack
