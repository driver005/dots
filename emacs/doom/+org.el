;;; +org.el -*- lexical-binding: t; -*-

;; Default org files location
(setq org-directory "~/org/")

;; Modern UI elements for org mode
(use-package! org-modern
  :hook (org-mode . org-modern-mode))

;; Grouped agenda views
(use-package! org-super-agenda
  :after org-agenda
  :config (org-super-agenda-mode 1))

;; Drag and drop images into org
(use-package! org-download
  :after org
  :config (org-download-enable))
