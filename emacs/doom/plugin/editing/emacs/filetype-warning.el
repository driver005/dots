;;; plugin/editing/emacs/filetype-warning.el -*- lexical-binding: t; -*-

;; Doom (like vanilla Emacs) silently opens a file with no matching major
;; mode in `fundamental-mode' - no syntax highlighting, no LSP, nothing.
;; Surface that instead of letting it pass quietly.
(defun +warn-unsupported-filetype-h ()
  "Log to *Messages* when the visited file has no major mode."
  (when (and buffer-file-name (eq major-mode 'fundamental-mode))
    (message "No major mode/language support for: %s"
             (file-name-nondirectory buffer-file-name))))

(add-hook 'find-file-hook #'+warn-unsupported-filetype-h)
