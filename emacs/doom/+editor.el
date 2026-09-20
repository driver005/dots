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
                 ("A | Org agenda" . org-agenda)
                 ("b | Default browser" . browse-url-of-file)
                 ("d | Start a debugger" . +debugger/start)
                 ("f | New frame" . make-frame)
                 ("F | Select frame" . select-frame-by-name)
                 ("r | REPL (other window)" . +eval/open-repl-other-window)
                 ("R | REPL (same window)" . +eval/open-repl-same-window)
                 ("t | Terminal (Eshell)" . eshell)
                 ("m | Git (Magit)" . magit-status)
                 ("c | Calculator" . calc)
                 ("p | System Monitor" . proced)))
         (map (make-sparse-keymap)))
    
    (set-keymap-parent map minibuffer-local-completion-map)
    (cl-loop for (key . cmd) in '(("-" . dired-jump)
                                  ("A" . org-agenda)
                                  ("b" . browse-url-of-file)
                                  ("d" . +debugger/start)
                                  ("f" . make-frame)
                                  ("F" . select-frame-by-name)
                                  ("r" . +eval/open-repl-other-window)
                                  ("R" . +eval/open-repl-same-window)
                                  ("t" . eshell)
                                  ("m" . magit-status)
                                  ("c" . calc)
                                  ("p" . proced))
             do (let ((func `(lambda () (interactive) (run-at-time 0 nil #',cmd) (abort-recursive-edit))))
                  (define-key map (kbd (concat "M-" key)) func)   ;; Left Alt (Meta)
                  (define-key map (kbd (concat "A-" key)) func)   ;; Right Alt (AltGr sometimes maps to A-)
                  (define-key map (kbd (concat "s-" key)) func)   ;; Windows/Super Key
                  (define-key map (kbd (concat "C-c " key)) func))) ;; Ctrl+C fallback

    (minibuffer-with-setup-hook
        (lambda () (use-local-map map))
      (let ((choice (completing-read "Launch App (Alt+Key for instant): " apps nil t)))
        (call-interactively (alist-get choice apps nil nil #'equal))))))

(map! :leader
      (:prefix-map ("o" . "open")
       :desc "App Picker" "o" #'+custom-emacs-app-picker))
