;;; +tools.el -*- lexical-binding: t; -*-

;; Inherit shell $PATH for compilers/LSPs
(use-package! exec-path-from-shell
  :when (memq window-system '(mac ns x pgtk))
  :init
  (exec-path-from-shell-initialize))

;; Warn when visiting files with no major mode
(defun +warn-unsupported-filetype-h ()
  "Log to *Messages* when the visited file has no major mode."
  (when (and buffer-file-name (eq major-mode 'fundamental-mode))
    (message "No major mode/language support for: %s"
             (file-name-nondirectory buffer-file-name))))

(add-hook 'find-file-hook #'+warn-unsupported-filetype-h)

;; Show TODOs/FIXMEs in git status
(use-package! magit-todos
  :after magit
  :config (magit-todos-mode 1))

;; Generate AI commit messages
(use-package! magit-gptcommit
  :after magit
  :init
  (require 'llm-openai)
  :custom
  (magit-gptcommit-llm-provider
   (make-llm-openrouter :key (lambda () (getenv "OPENROUTER_API_KEY"))
                         :chat-model "cohere/north-mini-code:free"))
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
  (add-hook 'git-commit-setup-hook #'magit-gptcommit-commit-accept))

;; Debug Adapter Protocol for Emacs
(use-package! dape
  :config
  (setq dape-buffer-window-arrangement 'right)
  (add-hook 'kill-emacs-hook #'dape-breakpoint-save)
  (add-hook 'after-init-hook #'dape-breakpoint-load)
  (dape-breakpoint-global-mode 1))

(map! :leader
      (:prefix ("d" . "debug")
       :desc "Start/attach"        "d" #'dape
       :desc "Restart"             "r" #'dape-restart
       :desc "Continue"            "c" #'dape-continue
       :desc "Next (step over)"    "n" #'dape-next
       :desc "Step in"             "i" #'dape-step-in
       :desc "Step out"            "o" #'dape-step-out
       :desc "Pause"               "p" #'dape-pause
       :desc "Disconnect (quit)"   "q" #'dape-disconnect
       :desc "Eval at point"       "e" #'dape-evaluate-expression
       :desc "Toggle breakpoint"   "b" #'dape-breakpoint-toggle
       :desc "Breakpoint remove all" "B" #'dape-breakpoint-remove-all
       :desc "Expr breakpoint"     "E" #'dape-breakpoint-expression
       :desc "Restart last"        "l" #'dape-last
       :desc "Info"                "I" #'dape-info))

;; Show dotfiles by default in Dired
(after! dired
  (setq dired-listing-switches "-algho --group-directories-first")
  (remove-hook 'dired-mode-hook #'dired-omit-mode)
  (add-hook 'dired-mode-hook (lambda () (dired-omit-mode -1)) t))
(after! dired
  (remove-hook 'dired-mode-hook #'+vc-gutter-enable-maybe-h))
