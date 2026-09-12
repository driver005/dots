;;; plugin/dev/tools/magit-extras.el -*- lexical-binding: t; -*-

(use-package! magit-todos
  :after magit
  :config (magit-todos-mode 1))

;; git-messenger was dropped - redundant with Doom's own native `SPC g B'
;; (magit-blame-addition), which already answers "why was this line
;; changed" (persistent margin annotation vs a one-off popup).

;; Gemini needs real billing (not covered by a Google subscription).
;; GitHub Models (tried next) was retired 2026-07-30 - dead endpoint, not
;; a config problem. Landed on OpenRouter's real free tier instead
;; (`llm-openrouter' struct lives inside llm-openai.el, not its own file)
;; - a `:free'-suffixed
;; model, no card required. OPENROUTER_API_KEY in ~/.bashrc.secrets, same
;; place as MISTRAL_API_KEY/VOYAGE_API_KEY. Free-model catalog shifts
;; often - re-check https://openrouter.ai/api/v1/models
;; (pricing.prompt/completion == "0") if this model ever disappears.
(use-package! magit-gptcommit
  :after magit
  :init
  (require 'llm-openai)
  :custom
  (magit-gptcommit-llm-provider
   (make-llm-openrouter :key (lambda () (getenv "OPENROUTER_API_KEY"))
                         :chat-model "cohere/north-mini-code:free"))
  ;; this free model does hidden "reasoning" before its real answer,
  ;; eating into whatever token budget a request gets - confirmed live
  ;; that 10 tokens gets nothing but reasoning, 100 gets a real answer.
  ;; nil (the default) risks the same starvation on real commit messages.
  (magit-gptcommit-llm-provider-max-tokens 1024)
  (llm-warn-on-nonfree nil)
  :config
  (magit-gptcommit-mode 1)
  (magit-gptcommit-status-buffer-setup)
  (map! :map git-commit-mode-map "C-c C-g" #'magit-gptcommit-commit-accept)
  (map! :leader
        (:prefix "g c"
         :desc "AI commit" "g" #'magit-gptcommit-generate
         :desc "Accept AI commit" "a" #'magit-gptcommit-commit-accept))
  (add-hook 'git-commit-setup-hook #'magit-gptcommit-generate))
