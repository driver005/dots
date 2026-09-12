;;; plugin/ai/gptel/config.el -*- lexical-binding: t; -*-

;; :tools llm (init.el) brings gptel/gptel-quick/gptel-magit/ob-gptel with
;; `SPC o l *' bindings, defaulting to OpenAI. Point it at Claude instead and
;; add a couple of alternate backends.
;;
;; API keys read from ~/.authinfo (never stored here), e.g.:
;;   machine api.anthropic.com login apikey password <key>
;;   machine api.deepseek.com  login apikey password <key>
(after! gptel
  ;; octocode (codebase graph/semantic search) and Tabby (repo-indexed
  ;; completion) auto-connect/auto-register per project on `gptel-mode-hook'
  ;; (see plugin/ai/octocode/config.el) - tell the model they're there so it
  ;; actually reaches for them instead of guessing blind.
  (setf (alist-get 'default gptel-directives)
        (concat "You are a large language model living in Emacs and a helpful "
                "assistant. Respond concisely. This project has octocode "
                "(codebase graph + semantic search, exposed as MCP tools) and "
                "Tabby (repo-indexed completion) connected - use octocode's "
                "tools to look up real code structure/definitions instead of "
                "guessing when relevant."))
  (setq gptel-system-prompt (alist-get 'default gptel-directives))
  (setq gptel-backend
        (gptel-make-anthropic "Claude"
          :stream t
          :key #'gptel-api-key))
  (gptel-make-deepseek "DeepSeek"
    :stream t
    :key #'gptel-api-key)
  (gptel-make-gemini "Gemini"
    :stream t
    :key #'gptel-api-key))
