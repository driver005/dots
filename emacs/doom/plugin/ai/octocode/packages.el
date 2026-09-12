;;; plugin/ai/octocode/packages.el -*- lexical-binding: t; no-byte-compile: t -*-

;; mcp.el: generic MCP client, connects Emacs to octocode's MCP server
;; (structural codebase graph - imports/calls/extends/implements via
;; tree-sitter, plus semantic search). Requires Emacs 30+. The `octocode`
;; binary itself is external (AUR: octocode), spawned as a stdio subprocess
;; per project - no persistent daemon/systemd service needed, unlike Tabby.
(package! mcp)

;; gptel-mcp.el: bridges mcp.el's connected servers/tools into gptel so
;; gptel chat can call them directly. Not on MELPA yet.
(package! gptel-mcp
  :recipe (:host github :repo "lizqwerscott/gptel-mcp.el"))
