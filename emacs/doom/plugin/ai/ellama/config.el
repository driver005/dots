;;; plugin/ai/ellama/config.el -*- lexical-binding: t; -*-

;; Ellama: dedicated LLM chat sessions via llm.el → OmniRoute gateway.
;;
;; Role split:
;;   gptel  — inline rewrite, org-babel, send-region, quick prompts
;;   ellama — named chat sessions, session history, multi-turn conversations
;;
;; Keybindings (all under SPC o l):
;;   e   +omniroute/ellama-chat   new/switch ellama chat session
;;   E   ellama-chat              ellama default chat (picks provider interactively)
;;   k   ellama-ask-about         ask about region/selection
;;   i   ellama-improve-code      improve selected code
;;   r   ellama-make-table        make table from selection
;;   SPC ellama-summarize          summarize buffer or region

(use-package! ellama
  :defer t
  :init
  ;; Lazy-load; triggered by keybindings below.
  (setq ellama-language "English"
        ;; Session files stored in ~/.ellama-sessions/ for persistence.
        ellama-sessions-directory (expand-file-name "~/.ellama-sessions/")
        ;; Use org-mode for chat buffers (matches gptel default-mode).
        ellama-chat-display-action-function #'display-buffer-full-frame
        ;; Reasonable translation/naming prefix.
        ellama-naming-scheme 'ellama-generate-name-by-llm
        ;; Show elapsed time in mode-line during streaming.
        ellama-show-elapsed-time t)

  :config
  (require 'llm-openai)

  ;; OmniRoute provider via OpenAI-compatible endpoint.
  (defun +ellama--omniroute-provider (&optional model)
    "Return an llm-openai-compatible provider pointing at OmniRoute."
    (make-llm-openai-compatible
     :url "http://localhost:20128/v1/"
     :key (lambda ()
            (or (getenv "OMNIROUTE_API_KEY")
                (getenv "OPENAI_API_KEY")
                "sk-omniroute"))
     :chat-model (or model "auto")))

  ;; Set as the default ellama provider.
  (setq ellama-provider (+ellama--omniroute-provider "auto"))

  ;; Extra named providers for quick switching (SPC o l E → ellama-chat prompts).
  (setq ellama-providers
        '(("auto"              . (lambda () (+ellama--omniroute-provider "auto")))
          ("claude-sonnet-4-6" . (lambda () (+ellama--omniroute-provider "claude-sonnet-4-6")))
          ("gemini-3.1-pro"    . (lambda () (+ellama--omniroute-provider "gemini-3.1-pro")))
          ("gemini-flash"      . (lambda () (+ellama--omniroute-provider "gemini-3.6-flash-low")))
          ("gpt-4o"            . (lambda () (+ellama--omniroute-provider "gpt-4o")))
          ("deepseek"          . (lambda () (+ellama--omniroute-provider "deepseek-chat"))))))


;; ---------------------------------------------------------------------------
;; Commands & keybindings
;; ---------------------------------------------------------------------------

;;;###autoload
(defun +omniroute/ellama-chat ()
  "Open a new ellama chat session via OmniRoute (model: auto)."
  (interactive)
  (require 'ellama)
  (let ((ellama-provider (+ellama--omniroute-provider "auto")))
    (ellama-chat)))

(map! :leader
      (:prefix ("o l" . "llm")
       :desc "Ellama chat"         "e" #'+omniroute/ellama-chat
       :desc "Ellama (pick model)" "E" #'ellama-chat
       :desc "Ask about region"    "k" #'ellama-ask-about
       :desc "Improve code"        "i" #'ellama-improve-code
       :desc "Summarize"           "," #'ellama-summarize))
