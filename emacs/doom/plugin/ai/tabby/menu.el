;;; plugin/ai/tabby/menu.el -*- lexical-binding: t; -*-

;; Ported from copilot.el's copilot-menu.el (MIT, github.com/copilot-emacs/copilot.el),
;; "Completions" group only. Dropped, with no tabby equivalent to point at:
;; - "Chat"/"Agent" groups: entirely copilot-chat.el calls, excluded per
;;   explicit request (no chat panel for tabby).
;; - "Account" group (login/logout/quota): GitHub OAuth account state -
;;   tabby's own auth is a static token in ~/.tabby-client/agent/config.toml,
;;   set up by tabby/tabby-install.sh, no interactive login flow exists.
;; - "Install/reinstall/uninstall server": copilot-language-server is an
;;   npm binary the elisp package manages directly; Tabby's server is the
;;   separately-managed `tabbyml.service' systemd unit (also via
;;   tabby-install.sh) - a different lifecycle model, nothing here to wire
;;   a menu entry to.
;; - "Panel completions": Copilot's own multi-suggestion browsing UI, no
;;   tabby.el equivalent exists today.
;;
;; Also dropped: copilot-menu.el's Emacs-27.2 compatibility shim (defining
;; the prefix as data, `eval'd only if `transient' is available, with a
;; placeholder `user-error' otherwise). Not relevant here - Doom already
;; depends on `transient' transitively via magit, so it's always present.

;;; Code:

(require 'transient)

(defun +tabby-menu--mode-description ()
  "Describe `tabby-mode' with its state in the current buffer."
  (format "Automatic completions [%s]" (if (bound-and-true-p tabby-mode) "on" "off")))

;;
;; The menu itself
;;

;;;###autoload (autoload 'tabby-menu "tabby-menu" nil t)
(transient-define-prefix tabby-menu ()
  "Transient menu for the most common tabby.el commands."
  [["Completions"
    ("t" tabby-mode
     :description +tabby-menu--mode-description
     :transient t)
    ("c" "Complete at point" tabby-complete)
    ("a" "Accept completion" tabby-accept-completion)]
   ["Server"
    ("r" "Force reindex now" +tabby-reindex-now)
    ("l" "Show server log" +tabby-show-log)
    ("o" "Open web UI" +tabby-open-ui)
    ("i" "Index this project" +tabby-index-project)]])

(provide 'tabby-menu)
;;; plugin/ai/tabby/menu.el ends here
