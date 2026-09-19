;;; +completion.el -*- lexical-binding: t; -*-

(after! corfu
  ;; Show current candidate inline
  (setq corfu-preview-current t)
  ;; Preselect the first option
  (setq corfu-preselect 'first))

(defface +corfu-preview-face
  '((t :inherit shadow))
  "Face for corfu's ghost-text preview overlay, distinct from real text.")

;; Apply shadow face to inline preview
(defun +corfu-preview-add-face (&rest _)
  (when (overlayp corfu--preview-ov)
    (dolist (prop '(after-string display))
      (when-let* ((val (overlay-get corfu--preview-ov prop))
                  ((stringp val)))
        (overlay-put corfu--preview-ov prop
                     (propertize val 'face '+corfu-preview-face))))))

(after! corfu
  (advice-add #'corfu--preview-current :after #'+corfu-preview-add-face))

;; Remember completion history
(use-package! corfu-history
  :hook (corfu-mode . corfu-history-mode))

;; Show documentation popups for candidates
(use-package! corfu-popupinfo
  :hook (corfu-mode . corfu-popupinfo-mode)
  :config
  (setq corfu-popupinfo-delay '(0.25 . 0.5))
  (defun +corfu-popupinfo-echo ()
    "Show the selected candidate's documentation in the echo area,
instead of `corfu-popupinfo''s side popup."
    (interactive)
    (if (< corfu--index 0)
        (user-error "No candidate selected")
      (let ((cand (nth corfu--index corfu--candidates)))
        (if-let* ((doc (corfu-popupinfo--get-documentation cand)))
            (message "%s" doc)
          (user-error "No documentation available for `%s'"
                      (substring-no-properties cand))))))
  (keymap-set corfu-map "M-e" #'+corfu-popupinfo-echo))

(after! corfu
  ;; Info buffer integration
  (require 'corfu-info))
