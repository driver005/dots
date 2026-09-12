;;; plugin/org/extras.el -*- lexical-binding: t; -*-

(use-package! org-modern
  :hook (org-mode . org-modern-mode))

(use-package! org-super-agenda
  :after org-agenda
  :config (org-super-agenda-mode 1))

(use-package! org-download
  :after org
  :config (org-download-enable))
