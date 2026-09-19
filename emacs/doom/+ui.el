;;; +ui.el -*- lexical-binding: t; -*-

;; Default Doom theme
(setq doom-theme 'doom-one)
;; Enable line numbers
(setq display-line-numbers-type t)

;; Remove window manager decorations
(add-to-list 'default-frame-alist '(undecorated . t))
;; Start fullscreen
(add-to-list 'default-frame-alist '(fullscreen . fullboth))

(when (memq (window-system) '(pgtk x))
  (add-hook 'server-after-make-frame-hook #'+wayland-focus-frame-h)
  (add-hook 'after-make-frame-functions #'+wayland-focus-frame-h)
  (add-hook 'window-setup-hook #'+wayland-focus-frame-h))

;; Fix frame focus under Wayland
(defun +wayland-focus-frame-h (&optional frame)
  (select-frame-set-input-focus (or frame (selected-frame))))

(after! treemacs
  ;; Follow active buffer in Treemacs
  (treemacs-follow-mode 1))

(use-package! rainbow-delimiters :commands rainbow-delimiters-mode)
(use-package! rainbow-mode :commands rainbow-mode)
(use-package! symbol-overlay :commands symbol-overlay-mode)

(map! :leader
      (:prefix "t"
       :desc "Rainbow delimiters" "R" #'rainbow-delimiters-mode
       :desc "Rainbow hex colors" "h" #'rainbow-mode
       :desc "Symbol overlay"     "o" #'symbol-overlay-mode))

(after! writeroom-mode
  (remove-hook 'writeroom-local-effects #'focus-mode))

(map! :leader
      (:prefix-map ("t" . "toggle")
       :desc "Dim blocks" "n" #'focus-mode))
