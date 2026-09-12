;;; $DOOMDIR/init.el -*- lexical-binding: t; -*-

;; This file controls what Doom modules are enabled and what order they load
;; in. Remember to run 'doom sync' after modifying it!

;; NOTE: Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;   documentation. There you'll find a link to Doom's Module Index where all of
;;   our modules are listed, including what flags they support.

;; NOTE: Move your cursor over a module's name (or its flags) and press 'K' (or
;;   'C-c c k' for non-vim users) to view its documentation. This works on flags
;;   as well (those symbols that start with a plus).
;;
;;   Alternatively, press 'gd' (or 'C-c c d') on a module to browse its
;;   directory (for easy access to its source code).

;;  RELOAD ENVIRONMENT ON STARTUP
(when (display-graphic-p)
  (let ((shell-path (shell-command-to-string "$SHELL -lc 'printf %s \"$PATH\"'")))
    (unless (string-empty-p shell-path)
      (setenv "PATH" shell-path)
      (setq exec-path (split-string shell-path path-separator)))))

;; The module list below is split one folder per category under plugin/,
;; grouped into a few umbrella folders (editing/, dev/, extras/), e.g.
;; plugin/dev/lang/modules.el holds the :lang list. `doom!' is a macro that
;; expects its arguments literally UNLESS the first item isn't a keyword, in
;; which case it evaluates them - so we hand it a single `append' call built
;; from each category file's contents instead.
(defun +dots-doom-category (path)
  "Read the single form in plugin/PATH/modules.el under DOOMDIR as data."
  (with-temp-buffer
    (insert-file-contents (expand-file-name (format "plugin/%s/modules.el" path) doom-user-dir))
    (read (current-buffer))))

;; Any future private modules live under plugin/ instead of the default
;; $DOOMDIR/modules/ - point Doom's module search path at our umbrella
;; folders instead. Doom's own built-in modules (core + community) are
;; untouched, only our private-module root is replaced.
(setq doom-module-load-path
      (list (expand-file-name "plugin/editing" doom-user-dir)
            (expand-file-name "plugin/dev" doom-user-dir)
            (expand-file-name "plugin/extras" doom-user-dir)
            (file-name-concat doom-emacs-dir "modules")
            (file-name-concat doom-emacs-dir "sources/doom+/modules")))

(doom!
 (append
  (+dots-doom-category "editing/input")
  (+dots-doom-category "editing/completion")
  (+dots-doom-category "editing/ui")
  (+dots-doom-category "editing/editor")
  (+dots-doom-category "editing/emacs")
  (+dots-doom-category "editing/checkers")
  (+dots-doom-category "editing/config")
  (+dots-doom-category "dev/term")
  (+dots-doom-category "dev/tools")
  (+dots-doom-category "dev/os")
  (+dots-doom-category "dev/lang")
  (+dots-doom-category "extras/email")
  (+dots-doom-category "extras/app")))
