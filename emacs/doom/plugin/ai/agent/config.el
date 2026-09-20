;;; plugin/ai/agent/config.el -*- lexical-binding: t; -*-

;; agent-shell: native Emacs shell for ACP (Agent Client Protocol) agents.
;; Requires the Claude bridge on PATH:
;;   npm install -g @agentclientprotocol/claude-agent-acp
;;
;; agent-shell spawns Claude as a totally separate process from Emacs -
;; connecting octocode to Emacs's own mcp.el/gptel-mcp bridge (see
;; plugin/ai/octocode/config.el) does nothing for THIS process; it never
;; sees that connection. ACP has its own native MCP registration instead
;; (`agent-shell-mcp-servers', part of the actual ACP protocol schema, not
;; an Emacs-side workaround) - stdio transport, same command octocode's
;; own +octocode-connect uses, with the project root resolved dynamically
;; per-session via the `agent-shell-cwd' lambda (each new agent-shell
;; session can be a different project).
(when (executable-find "octocode")
  (setq agent-shell-mcp-servers
        '(((name . "octocode")
           (command . "octocode")
           (args . (lambda ()
                      (list "mcp" "--path" (agent-shell-cwd))))
           (env . ())))))
;;
;; Own sub-group directly under `SPC o' (open), sibling of `l' (llm), `t'
;; (tabby), `g' (octocode) - same depth Doom itself uses (e.g. `SPC o a').
;; `c' for Claude - `a' itself is Doom's own org-agenda group (stock,
;; :lang org).

