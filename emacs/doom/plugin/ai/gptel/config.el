;;; plugin/ai/gptel/config.el -*- lexical-binding: t; -*-

;; :tools llm (init.el) brings gptel/gptel-quick/gptel-magit/ob-gptel with
;; `SPC o l *' bindings, defaulting to OpenAI. Point it at Claude instead and
;; add a couple of alternate backends.
;;
;; API keys read from ~/.authinfo (never stored here), e.g.::
;;   machine api.anthropic.com login apikey password <key>
;;   machine api.deepseek.com  login apikey password <key>
(after! gptel
  ;; octocode (codebase graph/semantic search) and Tabby (repo-indexed
  ;; completion) auto-connect/auto-register per project on `gptel-mode-hook'
  ;; (see plugin/ai/octocode/config.el) - tell the model they're there so it
  ;; actually reaches for them instead of guessing blind.
  (setf (alist-get 'default gptel-directives)
        (concat "You are an expert pair-programmer. Follow these core behavioral rules:\n"
                "1. STYLE (Caveman): Terse like smart caveman. All technical substance stays, only fluff dies. Drop articles, filler, pleasantries, hedging. Fragments OK. Code/symbols/errors exact. Pattern: [thing] [action] [reason]. [next step].\n"
                "2. STRUCTURE (ADHD): Lead with the next action (command, snippet, path). Number multi-step tasks. Restate state every turn. Suppress tangents. Concrete time estimates. Matter-of-fact errors. End with 1 concrete action.\n"
                "3. ANTI-SLOP: Zero AI fluff. Banned words: delve, foster, leverage, utilize, facilitate, empower, streamline, robust, cutting-edge, tapestry, realm, beacon, multifaceted, meticulous, intricate, transformative, elevate, embark, supercharge, harness. No throat-clearing openers, no binary contrasts, no summary-recap endings.\n"
                "Tools: octocode (codebase graph + semantic search) and Tabby connected - use octocode's tools to look up real code definitions instead of guessing."))
  (setq gptel-system-prompt (alist-get 'default gptel-directives))
  ;; OmniRoute: Local Universal AI Gateway (http://localhost:20128) - Default backend
  (setq gptel-backend
        (gptel-make-openai "OmniRoute"
          :host "localhost:20128"
          :endpoint "/v1/chat/completions"
          :stream t
          :protocol "http"
          :models '("auto"
                    "opencode/big-pickle"
                    "claude-sonnet-4-6"
                    "gemini-3.1-pro"
                    "gemini-3.6-flash-low"
                    "gpt-4o"
                    "gpt-4o-mini"
                    "deepseek-chat")
          :key (lambda () (or (getenv "OMNIROUTE_API_KEY")
                              (getenv "OPENAI_API_KEY")
                              "sk-omniroute"))))
  (setq gptel-model "auto")

  ;; Fallback direct backends
  (gptel-make-anthropic "Claude"
    :stream t
    :key #'gptel-api-key)
  (gptel-make-deepseek "DeepSeek"
    :stream t
    :key #'gptel-api-key)
  (gptel-make-gemini "Gemini"
    :stream t
    :key #'gptel-api-key))


;; ---------------------------------------------------------------------------
;; Dedicated OmniRoute Chat buffer
;; ---------------------------------------------------------------------------
;;
;; `+omniroute/chat'  — SPC o l c — opens (or switches to) a named
;;   *OmniRoute Chat* buffer pre-wired to the OmniRoute backend / model "auto".
;; `+omniroute/popup' — SPC o l C — same but in a popup (30% bottom split).
;;
;;;###autoload
(defun +omniroute/chat ()
  "Open (or switch to) the dedicated *OmniRoute Chat* gptel buffer.
Always uses the OmniRoute backend with model \"auto\"."
  (interactive)
  (let* ((buf-name "*OmniRoute Chat*")
         (backend (alist-get "OmniRoute" gptel--backends nil nil #'equal))
         (gptel-backend (or backend gptel-backend))
         (gptel-model "auto"))
    (if (get-buffer buf-name)
        (switch-to-buffer buf-name)
      (gptel buf-name))
    (with-current-buffer buf-name
      (setq-local gptel-backend (or backend gptel-backend))
      (setq-local gptel-model "auto"))))

;;;###autoload
(defun +omniroute/popup ()
  "Open the *OmniRoute Chat* gptel buffer in a bottom popup."
  (interactive)
  (let ((gptel-display-buffer-action
         '(display-buffer-in-side-window
           (side . bottom)
           (slot . 0)
           (window-height . 0.35))))
    (+omniroute/chat)))

;; Map under SPC o l
(map! :leader
      (:prefix ("l" . "llm")
       :desc "OmniRoute chat" "c" #'+omniroute/chat
       :desc "OmniRoute popup" "C" #'+omniroute/popup))
