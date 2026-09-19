;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Core extensions
;; Garbage collector and Emacs core speed tuning
(load! "+perf")
;; Themes, visual tweaks, and window decorations
(load! "+ui")
;; Evil tricks, text manipulation, and core editing
(load! "+editor")
;; Boolean and number toggling
(load! "+toggle")
;; Corfu autocomplete interface and behavior
(load! "+completion")
;; Org-mode modernizations and agenda setup
(load! "+org")
;; External tools (Git, Debugger, Dired, etc.)
(load! "+tools")

;; Keybindings & Languages
;; Custom keybinding descriptions and overrides
(load! "+which-key")
;; Language-specific server configurations
(load! "+langs")

;; Private AI Modules
;; GPTel configuration
(load! "plugin/ai/gptel/config")
;; Agent configuration
(load! "plugin/ai/agent/config")
;; Tabby code completion
(load! "plugin/ai/tabby/config")
;; Tabby load balancer
(load! "plugin/ai/tabby/balancer")
;; Tabby UI menu
(load! "plugin/ai/tabby/menu")
;; Tabby NES integration
(load! "plugin/ai/tabby/nes")
;; Octocode integration
(load! "plugin/ai/octocode/config")
