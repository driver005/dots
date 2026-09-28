(in-package :lem-user)

;;; vi keybindings
(lem-vi-mode:vi-mode)

;;; Drop Emacs keybindings.
;;; vi-mode keeps *global-keymap* (Emacs bindings) as fallback, so C-f, M-f,
;;; C-x C-s etc. still fire in INSERT state. Strip every Ctrl/Meta prefix from
;;; it, except C-g (abort) and M-x (command palette).
(defun keep-key-p (key)
  (let ((sym (lem-core::key-sym key))
        (ctrl (lem-core::key-ctrl key))
        (meta (lem-core::key-meta key)))
    (or (and ctrl (not meta) (equal sym "g"))
        (and meta (not ctrl) (equal sym "x")))))

(defun disable-emacs-keybindings ()
  (setf (lem-core::keymap-prefixes lem:*global-keymap*)
        (remove-if (lambda (prefix)
                     (let ((key (lem-core::prefix-key prefix)))
                       (and (or (lem-core::key-ctrl key) (lem-core::key-meta key))
                            (not (keep-key-p key)))))
                   (lem-core::keymap-prefixes lem:*global-keymap*)))
  (lem-core::invalidate-keybinding-cache lem:*global-keymap*))

(disable-emacs-keybindings)

;;; SPC leader: Doom-style which-key popup via Lem's bundled lem/transient.
;;; Adapted from theangelperalta/dotfiles (lem/init/keybindings.lisp).
;;; Space is bound to the menu directly, so leave vi-mode's `leader-key' at its
;;; default; setting it to "Space" would stop the "Space" binding from matching.
(lem/transient:define-transient *leader-keymap*
  :description "Leader"
  :display-style :row

  (:keymap
   :display-style :column
   :description "file"
   (:key "f f" :suffix 'lem:find-file              :description "find file")
   (:key "f r" :suffix 'lem:find-recent-file       :description "recent files")
   (:key "f s" :suffix 'lem:save-current-buffer    :description "save file")
   (:key "f S" :suffix 'lem:save-some-buffers      :description "save all")
   (:key "f t" :suffix 'lem/filer:filer            :description "file tree"))

  (:keymap
   :display-style :column
   :description "buffer"
   (:key "b b" :suffix 'lem:select-buffer                :description "switch buffer")
   (:key "b l" :suffix 'lem/list-buffers:list-buffers    :description "list buffers")
   (:key "b k" :suffix 'lem:kill-buffer                  :description "kill buffer")
   (:key "b n" :suffix 'lem:next-buffer                  :description "next buffer")
   (:key "b p" :suffix 'lem:previous-buffer              :description "previous buffer"))

  (:keymap
   :display-style :column
   :description "window"
   (:key "w h" :suffix 'lem:window-move-left                  :description "move left")
   (:key "w l" :suffix 'lem:window-move-right                 :description "move right")
   (:key "w k" :suffix 'lem:window-move-up                    :description "move up")
   (:key "w j" :suffix 'lem:window-move-down                  :description "move down")
   (:key "w s" :suffix 'lem:split-active-window-vertically    :description "split vertically")
   (:key "w v" :suffix 'lem:split-active-window-horizontally  :description "split horizontally")
   (:key "w c" :suffix 'lem:delete-active-window              :description "close window")
   (:key "w o" :suffix 'lem:delete-other-windows              :description "close others")
   (:key "w w" :suffix 'lem:next-window                       :description "other window"))

  (:keymap
   :display-style :column
   :description "project"
   (:key "p f" :suffix 'lem-core/commands/project:project-find-file      :description "find file in project")
   (:key "p p" :suffix 'lem-core/commands/project:project-switch         :description "switch project")
   (:key "p d" :suffix 'lem-core/commands/project:project-root-directory :description "project directory")
   (:key "p k" :suffix 'lem-core/commands/project:project-kill-buffers   :description "kill project buffers"))

  (:keymap
   :display-style :column
   :description "search"
   (:key "s g" :suffix 'lem/grep:grep          :description "grep")
   (:key "s p" :suffix 'lem/grep:project-grep  :description "project grep"))

  (:keymap
   :display-style :column
   :description "eval"
   (:key "e e" :suffix 'lem-lisp-mode:lisp-eval-last-expression :description "eval last expr")
   (:key "e f" :suffix 'lem-lisp-mode:lisp-load-file            :description "load file"))

  (:keymap
   :display-style :column
   :description "code"
   (:key "c e" :suffix 'lem-lisp-mode:lisp-compile-defun         :description "compile defun")
   (:key "c b" :suffix 'lem-lisp-mode:lisp-compile-and-load-file :description "compile buffer")
   (:key "c r" :suffix 'lem-lisp-mode:lisp-compile-region        :description "compile region"))

  (:keymap
   :display-style :column
   :description "help"
   (:key "h k" :suffix 'lem:describe-key       :description "describe key")
   (:key "h b" :suffix 'lem:describe-bindings  :description "describe bindings")
   (:key "h m" :suffix 'lem:describe-mode      :description "describe mode")
   (:key "h a" :suffix 'lem:apropos-command    :description "apropos command"))

  (:keymap
   :display-style :column
   :description "toggle"
   (:key "t l" :suffix 'lem/line-numbers:toggle-line-numbers :description "line numbers")
   (:key "t t" :suffix 'lem:load-theme                       :description "choose theme"))

  (:keymap
   :display-style :column
   :description "open"
   (:key "o p" :suffix 'lem/filer:filer :description "project tree")))

;; Space would otherwise shadow the leader prefix (stock: forward-char).
(undefine-key lem-vi-mode:*motion-keymap* "Space")
(define-key lem-vi-mode:*normal-keymap* "Space" *leader-keymap*)
