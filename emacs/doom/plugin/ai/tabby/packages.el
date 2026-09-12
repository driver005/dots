;;; plugin/ai/tabby/packages.el -*- lexical-binding: t; no-byte-compile: t -*-

;; tabby.el: ghost-text tab completion backed by a self-hosted Tabby server
;; (completion + real repo-index awareness, see tabby/ for server setup).
;; Requires Node.js v18+ (already on PATH).
(package! tabby
  :recipe (:host github :repo "alan-w-255/tabby.el" :files ("*.el" "node_scripts")))
