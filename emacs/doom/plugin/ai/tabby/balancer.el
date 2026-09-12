;;; plugin/ai/tabby/balancer.el -*- lexical-binding: t; -*-

;; Ported from copilot.el's copilot-balancer.el (MIT, github.com/copilot-emacs/copilot.el)
;; and adapted for tabby.el - the algorithm below is fully generic and
;; backend-agnostic. Tabby's LLM can produce the same class of
;; mismatched-parens completions in Lisp modes that Copilot's does: this
;; trims excess trailing closers from the suggestion, then computes which
;; closers are actually needed to keep the surrounding top-level form
;; balanced. Parsing is done via Emacs's built-in `parse-partial-sexp', so
;; comments, strings, and escape sequences are handled correctly through
;; syntax tables.
;;
;; One deliberate simplification from the original: copilot's
;; `copilot-balancer-fix-completion' returns `(start end completion)'
;; because it can also adjust the replaced START/END - the "infix-fixup"
;; case, for an odd-quote completion landing right before an existing
;; closing quote. tabby.el's own `tabby-accept-completion' only takes a
;; plain string->string TRANSFORM-FN (see `plugin/ai/tabby/config.el'), not
;; a region-adjusting one, so that case (and its helper,
;; `copilot-balancer--odd-quotes-p') is dropped here; `tabby-balancer-fix-completion'
;; always returns just the fixed string. The "preserve a replaced region's
;; own trailing closers when it's replacing text inside a string/comment"
;; logic is unrelated to that and kept as-is.

;;; Code:

(require 'cl-lib)

;; A real `defcustom' here, not a bare forward-declaration like copilot's:
;; copilot-balancer.el's `(defvar copilot-enable-parentheses-balancer)' is
;; just a forward-declare because the actual defcustom lives in copilot.el's
;; main file, which requires this one. tabby.el has no equivalent main-file
;; defcustom, so this is the only place for it.
(defcustom tabby-enable-parentheses-balancer t
  "Whether to balance parentheses in Lisp-mode tabby completions."
  :group 'tabby
  :type 'boolean)

(defvar tabby-balancer-lisp-modes '( emacs-lisp-mode
                                      lisp-mode
                                      lisp-interaction-mode
                                      scheme-mode
                                      clojure-mode)
  "List of Lisp modes to balance.")

(defun tabby-balancer-trim-closing-pairs-at-end (s)
  "Trim closing brackets from the end of string S.
Only trims `)' `]' `}' -- not double quotes."
  (let ((i (length s)))
    (while (and (> i 0)
                (memq (aref s (1- i)) '(?\) ?\] ?\}))
                (or (< i 2)
                    (/= (aref s (- i 2)) ?\\)))
      (cl-decf i))
    (substring s 0 i)))

(defun tabby-balancer--compute-closers (prefix completion suffix syntax-table)
  "Compute closing delimiters needed to balance PREFIX + COMPLETION + SUFFIX.
Uses SYNTAX-TABLE for parsing.  Returns a string of closing characters."
  (with-temp-buffer
    (set-syntax-table syntax-table)
    (insert prefix completion suffix)
    (let* ((state (parse-partial-sexp (point-min) (point-max)))
           (open-positions (nth 9 state))
           (closers ""))
      (dolist (pos open-positions)
        (let ((closer (matching-paren (char-after pos))))
          (when closer
            (setq closers (concat (string closer) closers)))))
      closers)))

(defun tabby-balancer--fix-lisp (start end completion)
  "Fix Lisp COMPLETION from START to END by balancing delimiters.
Returns the fixed string (not a `(start end completion)' triple - see
the simplification note at the top of this file)."
  (let* ((trimmed (tabby-balancer-trim-closing-pairs-at-end completion))
         (prefix (save-excursion
                   (save-restriction
                     (widen)
                     (goto-char start)
                     (condition-case nil
                         (beginning-of-defun)
                       (scan-error (goto-char (point-min))))
                     (buffer-substring-no-properties (point) start))))
         (suffix (save-excursion
                   (save-restriction
                     (widen)
                     (goto-char end)
                     (condition-case nil
                         (end-of-defun)
                       (scan-error (goto-char (point-max))))
                     (buffer-substring-no-properties end (point)))))
         (closers (tabby-balancer--compute-closers
                   prefix trimmed suffix (syntax-table)))
         (replaced-closers
          (when (< start end)
            (let ((ppss (syntax-ppss start)))
              (when (or (nth 3 ppss) (nth 4 ppss))
                (let* ((replaced (buffer-substring-no-properties start end))
                       (replaced-trimmed
                        (tabby-balancer-trim-closing-pairs-at-end replaced)))
                  (substring replaced (length replaced-trimmed))))))))
    (concat trimmed closers (or replaced-closers ""))))

(defun tabby-balancer-fix-completion (start end completion)
  "Return COMPLETION, balanced, if START to END is in a Lisp mode buffer.
Otherwise returns COMPLETION unchanged."
  (if (and tabby-enable-parentheses-balancer
           (apply #'derived-mode-p tabby-balancer-lisp-modes))
      (tabby-balancer--fix-lisp start end completion)
    completion))

(provide 'tabby-balancer)
;;; tabby-balancer.el ends here
