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
      (:prefix "o"
       :desc "App Picker (Vertico)" "o" #'+custom-emacs-app-picker))
