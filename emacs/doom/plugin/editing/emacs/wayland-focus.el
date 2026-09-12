;;; plugin/editing/emacs/wayland-focus.el -*- lexical-binding: t; -*-

;; GNOME/mutter's Wayland focus-stealing prevention leaves a freshly-launched
;; GUI frame mapped but unfocused - the launching terminal (kitty) stays
;; focused - because a raw `emacs` invocation carries no xdg-activation
;; token. Emacs asking mutter to focus *itself* right after the frame is
;; created is allowed even without a token, so force it on every new frame
;; (initial startup frame + emacsclient -c frames alike).
(when (memq (window-system) '(pgtk x))
  (add-hook 'server-after-make-frame-hook #'+wayland-focus-frame-h)
  (add-hook 'after-make-frame-functions #'+wayland-focus-frame-h)
  (add-hook 'window-setup-hook #'+wayland-focus-frame-h))

(defun +wayland-focus-frame-h (&optional frame)
  (select-frame-set-input-focus (or frame (selected-frame))))
