;;; +editor.el -*- lexical-binding: t; -*-

;; Standard 2-space indentation
(setq-default tab-width 4
              standard-indent 4
              evil-shift-width 4
              c-basic-offset 4)

;; Live preview for regex replace
(use-package! visual-regexp
  :bind ("C-c q" . vr/query-replace))

(use-package! visual-regexp-steroids
  :after visual-regexp)

;; Simple save hotkey
(global-set-key (kbd "C-s") #'save-buffer)

(defun +save-buffer-and-normal-state ()
  "Save the buffer, then return to evil normal state."
  (interactive)
  (save-buffer)
  (evil-normal-state))

(map! :i "C-s" #'+save-buffer-and-normal-state)

;; Abort multiedit with escape
(after! evil-multiedit
  (map! :map evil-multiedit-mode-map
        :n "<escape>" #'evil-multiedit-abort))

;; Nuke the file submenu and make SPC f open find-file directly
(map! :leader
      "f" nil
      :desc "Find file" "f" #'find-file)

;; Remove redundant SPC . binding since SPC f handles it now
(map! :leader
      "." nil)

;; Custom Emacs App Picker (Mirror of SPC o)
(defun +custom-emacs-app-picker ()
  "A custom app launcher mirroring the SPC o menu using Vertico UI."
  (interactive)
  (let* ((apps '(("- | Dired" . dired-jump)
                 ("b | Default browser" . browse-url-of-file)
                 ("d | Start a debugger" . +debugger/start)
                 ("f | New frame" . make-frame)
                 ("F | Select frame" . select-frame-by-name)
                 ("r | REPL (other window)" . +eval/open-repl-other-window)
                 ("R | REPL (same window)" . +eval/open-repl-same-window)
                 ("m | Git (Magit)" . magit-status)
                 ("t | Ghostel popup" . +ghostel/toggle)
                 ("T | Ghostel here" . +ghostel/here)
                 ("c | Claude Agent Shell" . agent-shell)
                 ("e | Notmuch Email" . =notmuch)
                 ("o | Octocode Status" . +octocode-status)
                 ("p | Treemacs Sidebar" . +treemacs/toggle)
                 ("y | Tabby Menu" . tabby-menu)
                 ("C | Calculator" . calc)
                 ("P | System Monitor" . proced)))
         (map (make-sparse-keymap)))
    
    (set-keymap-parent map vertico-map)
    (cl-loop for (key . cmd) in '(("-" . dired-jump)
                                  ("b" . browse-url-of-file)
                                  ("d" . +debugger/start)
                                  ("f" . make-frame)
                                  ("F" . select-frame-by-name)
                                  ("r" . +eval/open-repl-other-window)
                                  ("R" . +eval/open-repl-same-window)
                                  ("m" . magit-status)
                                  ("t" . +ghostel/toggle)
                                  ("T" . +ghostel/here)
                                  ("c" . agent-shell)
                                  ("e" . =notmuch)
                                  ("o" . +octocode-status)
                                  ("p" . +treemacs/toggle)
                                  ("y" . tabby-menu)
                                  ("C" . calc)
                                  ("P" . proced))
             do (let* ((func `(lambda () (interactive) (run-at-time 0 nil #',cmd) (abort-recursive-edit)))
                       (altgr-char (cdr (assoc key '(("-" . "¥") ("b" . "·") ("d" . "ð") 
                                                     ("r" . "ë") ("R" . "Ë") ("m" . "µ") 
                                                     ("t" . "þ") ("T" . "Þ") ("c" . "©") ("e" . "é")
                                                     ("o" . "ó") ("p" . "ö") ("y" . "ü") ("C" . "¢") ("P" . "Ö"))))))
                  (define-key map (kbd (concat "M-" key)) func)
                  (define-key map (kbd (concat "s-" key)) func)
                  (define-key map (kbd (concat "C-c " key)) func)
                  (when altgr-char
                    (define-key map (kbd altgr-char) func))))

    (minibuffer-with-setup-hook
        (lambda () (use-local-map map))
      (let ((choice (completing-read "Launch App (Alt+Key for instant): " apps nil t)))
        (call-interactively (alist-get choice apps nil nil #'equal))))))

;; Move all llm bindings from SPC o l to SPC l
;; We wrap this in a check so it doesn't crash on subsequent reloads
;; when SPC o is already a command instead of a prefix!
(when (keymapp (lookup-key doom-leader-map (kbd "o")))
  (map! :leader "l" (lookup-key doom-leader-map (kbd "o l"))))

;; Override the entire SPC o prefix and replace it with our custom App Picker
(map! :leader
      "o" nil
      :desc "App Picker" "o" #'+custom-emacs-app-picker)

;; Add ChatGPT and Gemini to online search (SPC s o)
(add-to-list '+lookup-provider-url-alist '("ChatGPT" "https://chatgpt.com/?q=%s"))
(add-to-list '+lookup-provider-url-alist '("Google Gemini" "https://gemini.google.com/app?q=%s"))
