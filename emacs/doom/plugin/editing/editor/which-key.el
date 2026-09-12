;;; plugin/editing/editor/which-key.el -*- lexical-binding: t; -*-

(after! which-key
  (setq which-key-show-operator-state-maps t))

(defun +which-key-scoped-replacement (expected label)
  "Swap in LABEL only when the raw bound command is EXPECTED (a string,
or list of strings). Anything else is passed through unchanged."
  (let ((expected (if (listp expected) expected (list expected))))
    (lambda (key-binding)
      (if (member (cdr key-binding) expected)
          (cons (car key-binding) label)
        key-binding))))

(defun +which-key-scoped-replacements (pairs)
  "PAIRS is a list of (EXPECTED-COMMAND . LABEL). Like
`+which-key-scoped-replacement' but for one key shared by several
distinct commands across different evil states (e.g. C-e means
something different in motion-state vs insert-state - stack one entry
per state's section, each only recognizing its own command)."
  (lambda (key-binding)
    (or (seq-some (lambda (pair)
                     (and (equal (cdr key-binding) (car pair))
                          (cons (car key-binding) (cdr pair))))
                   pairs)
        key-binding)))

(defconst +which-key-noise-prefixes '("evil-" "doom/" "doom-" "better-jumper-"))

(defun +which-key-generic-cleanup (key-binding)
  (let ((label (cdr key-binding)))
    (if (and (stringp label)
             (not (string-match-p " " label))
             (not (string-prefix-p "group:" label))
             (string-match-p "[-/:]" label))
        (let ((clean label) (changed t))
          (while changed
            (setq changed nil)
            (when (string-match "\\`\\+[^/]+/" clean)
              (setq clean (substring clean (match-end 0)) changed t))
            (when (string-prefix-p "+" clean)
              (setq clean (substring clean 1) changed t))
            (dolist (prefix +which-key-noise-prefixes)
              (when (string-prefix-p prefix clean)
                (setq clean (substring clean (length prefix)) changed t))))
          (setq clean (string-trim (replace-regexp-in-string "[-/:_]+" " " clean)))
          (if (string-empty-p clean) key-binding (cons (car key-binding) clean)))
      key-binding)))

(with-eval-after-load 'which-key
  (add-to-list 'which-key-replacement-alist (cons '(nil) #'+which-key-generic-cleanup)))

(after! which-key
  (which-key-add-key-based-replacements
   "RET" (+which-key-scoped-replacement "evil-ret" "down, non-blank")
   "%" (+which-key-scoped-replacement "evil-jump-item" "matching bracket")
   "_" (+which-key-scoped-replacement "evil-next-line-1-first-non-blank" "down N-1, non-blank")
   "-" (+which-key-scoped-replacement "evil-previous-line-first-non-blank" "up, non-blank")
   "z-" (+which-key-scoped-replacement "evil-scroll-line-to-bottom-first-non-blank" "scroll bottom")
   "z." (+which-key-scoped-replacement "evil-scroll-line-to-center-first-non-blank" "scroll center")
   "z RET" (+which-key-scoped-replacement "evil-scroll-line-to-top-first-non-blank" "scroll top")
   "z <return>" (+which-key-scoped-replacement "evil-scroll-line-to-top-first-non-blank" "scroll top")
   "g*" (+which-key-scoped-replacement "evil-ex-search-unbounded-word-forward" "WORD forward")
   "g#" (+which-key-scoped-replacement "evil-ex-search-unbounded-word-backward" "WORD back")
   "g <home>" (+which-key-scoped-replacement "evil-first-non-blank-of-visual-line" "visual line start")
   "g^" (+which-key-scoped-replacement "evil-first-non-blank-of-visual-line" "visual line start")
   "f" (+which-key-scoped-replacement '("evil-find-char" "evil-snipe-f") "find char")
   "F" (+which-key-scoped-replacement '("evil-find-char-backward" "evil-snipe-F") "find char back")
   "t" (+which-key-scoped-replacement '("evil-find-char-to" "evil-snipe-t") "till char")
   "T" (+which-key-scoped-replacement '("evil-find-char-to-backward" "evil-snipe-T") "till char back")
   "i" (+which-key-scoped-replacement "prefix" "inner")
   "a" (+which-key-scoped-replacement "prefix" "around")
   "gss" (+which-key-scoped-replacement "evil-avy-goto-char-2" "EM 2-char")
   "gsw" (+which-key-scoped-replacement "evilem-motion-forward-word-begin" "EM word")
   "gsb" (+which-key-scoped-replacement "evilem-motion-backward-word-begin" "EM back word")
   "gse" (+which-key-scoped-replacement "evilem-motion-forward-word-end" "EM end word")
   "gsf" (+which-key-scoped-replacement "evilem-motion-find-char" "EM find char")
   "gst" (+which-key-scoped-replacement "evilem-motion-find-char-to" "EM till char")
   "gsn" (+which-key-scoped-replacement "evilem-motion-search-next" "EM next match")
   "gsN" (+which-key-scoped-replacement "evilem-motion-search-previous" "EM prev match")
   "gs*" (+which-key-scoped-replacement "evilem-motion-search-word-forward" "EM word fwd")
   "gs#" (+which-key-scoped-replacement "evilem-motion-search-word-backward" "EM word back")
   "gs -" (+which-key-scoped-replacement "evilem-motion-previous-line-first-non-blank" "EM prev-line")
   "gs A" (+which-key-scoped-replacement "evilem--motion-function-evil-backward-arg" "EM back-arg")
   "aB" (+which-key-scoped-replacement "evil-textobj-anyblock-a-block" "a block (any)")
   "iB" (+which-key-scoped-replacement "evil-textobj-anyblock-inner-block" "inner block (any)")
   "aj" (+which-key-scoped-replacement "evil-indent-plus-a-indent-up-down" "a below (indent)")
   "ak" (+which-key-scoped-replacement "evil-indent-plus-a-indent-up" "a above (indent)")
   "ij" (+which-key-scoped-replacement "evil-indent-plus-i-indent-up-down" "inner below (indent)")
   "ik" (+which-key-scoped-replacement "evil-indent-plus-i-indent-up" "inner above (indent)")
   "]h" "next heading" "[h" "prev heading"
   "[#" "prev preproc directive" "[m" "prev method start"
   "<down-mouse-1>" "drag select"
   "<home>" "line start" "<end>" "line end"
   "C-^" "alt buffer"
   "v" (+which-key-scoped-replacement "evil-visual-char" "visual char")
   "C-]" "jump to tag"
   "C-z" "emacs state"
   "!" "shell command"
   "Y" "yank line" "y" "yank"
   "M" "screen middle"))

(after! which-key
  (which-key-add-key-based-replacements
   "C-g" "escape"
   "c" (+which-key-scoped-replacement "evil-line-or-visual-line" "Change line")
   "d" (+which-key-scoped-replacement "evil-line-or-visual-line" "Delete line")
   "y" (+which-key-scoped-replacement "evil-line-or-visual-line" "Yank line")
   "=" (+which-key-scoped-replacement "evil-line" "Indent line")))

(after! which-key
  (which-key-add-key-based-replacements
   "gc" (+which-key-scoped-replacement "evilnc-comment-operator" "comment")
   "<escape> D" (+which-key-scoped-replacement "evil-multiedit-match-symbol-and-prev" "multiedit prev")
   "<escape> d" (+which-key-scoped-replacement "evil-multiedit-match-symbol-and-next" "multiedit next")
   "gF" (+which-key-scoped-replacement "evil-find-file-at-point-with-line" "find file at line")
   "zN" (+which-key-scoped-replacement "doom/widen-indirectly-narrowed-buffer" "widen buffer")
   "zw" (+which-key-scoped-replacement "+spell/remove-word" "unmark misspelled")
   "zg" (+which-key-scoped-replacement "+spell/add-word" "mark correct")
   "g=" (+which-key-scoped-replacement "evil-numbers/inc-at-pt" "increment number")
   "g-" (+which-key-scoped-replacement "evil-numbers/dec-at-pt" "decrement number")
   "s" (+which-key-scoped-replacements
        '(("evil-substitute" . "Substitute")
          ("evil-snipe-s" . "Snipe forward")))
   "S" (+which-key-scoped-replacements
        '(("evil-change-whole-line" . "change line")
          ("evil-snipe-S" . "Snipe backward")))
   "C-<tab>" (+which-key-scoped-replacement "aya-create" "create snippet")
   "M-d" "multi-edit next match" "M-D" "multi-edit prev match"
   "gzd" "MC next-match" "gzD" "MC prev-match"
   "gzs" "MC skip-next" "gzS" "MC skip-prev"
   "gzc" "MC next" "gzC" "MC prev"
   "gzj" "MC down" "gzk" "MC up"
   "gzn" "MC next-cursor" "gzN" "MC last-cursor"
   "gzp" "MC prev-cursor" "gzP" "MC first-cursor"
   "gzz" "MC toggle"
   "gzt" "MC toggle all" "gzu" "MC undo one" "gzm" "MC all" "gzq" "MC undo all"
   "C--" "shrink text" "C-+" "reset font" "C-S-f" "fullscreen"
   "C-S-<return>" "newline above" "C-<return>" "newline below"
   "DEL" "left" "&" "repeat subst" "<deletechar>" "delete char"
   "P" "paste before" "m" "set mark" "<insertchar>" "insert"
   "D" "delete line" "C" "change line"
   "C-." "repeat pop"))

(after! which-key
  (which-key-add-key-based-replacements
   "g=" (+which-key-scoped-replacement "evil-numbers/inc-at-pt-incremental" "increment number")
   "g-" (+which-key-scoped-replacement "evil-numbers/dec-at-pt-incremental" "decrement number")
   "I" (+which-key-scoped-replacement "evil-insert" "block insert")
   "A" (+which-key-scoped-replacement "evil-append" "block append")
   "C-<tab>" (+which-key-scoped-replacement "aya-create" "create snippet")
   "zn" "narrow buffer"
   "gzd" "MC next-match" "gzD" "MC prev-match"
   "gzs" "MC skip-next" "gzS" "MC skip-prev"
   "gzc" "MC next" "gzC" "MC prev"
   "gzj" "MC down" "gzk" "MC up"
   "gzn" "MC next-cursor" "gzN" "MC last-cursor"
   "gzp" "MC prev-cursor" "gzP" "MC first-cursor"
   "gzz" "MC toggle" "gzI" "MC sel-start" "gzA" "MC sel-end"
   "#" (+which-key-scoped-replacement "evil-visualstar/begin-search-backward" "visualstar back")
   "*" (+which-key-scoped-replacement "evil-visualstar/begin-search-forward" "visualstar fwd")
   "C-g" "escape"
   "U" "Uppercase"))

(after! which-key
  (which-key-add-key-based-replacements
   "C-e" (+which-key-scoped-replacements
          '(("evil-scroll-line-down" . "scroll down")
            ("doom/forward-to-last-non-comment-or-eol" . "end of code line")))
   "C-u" (+which-key-scoped-replacements
          '(("evil-scroll-up" . "scroll up")
            ("evil-delete-back-to-indentation" . "delete to indent")))
   "C-@" (+which-key-scoped-replacement "evil-paste-last-insertion-and-stop-insert" "paste, exit")
   "C-<tab>" (+which-key-scoped-replacement "aya-expand" "expand snippet")
   "S-RET" "newline, indent" "S-<return>" "newline, indent"
   "C-S-RET" "newline above" "C-RET" "newline below"
   "C-g" "escape" "S-<right>" "word right" "S-<left>" "word left"
   "C-a" "bol/indent" "C-q" "quoted insert" "C-z" "emacs state"
   "<delete>" "delete char"))

(after! which-key
  (which-key-add-key-based-replacements
   "m v" "maximize vertically" "m s" "maximize horizontally"
   "C-6" "last buffer"
   "V" (+which-key-scoped-replacement "+evil/window-vsplit-and-follow" "vsplit + follow")
   "S" (+which-key-scoped-replacement "+evil/window-split-and-follow" "split + follow")
   "W" (+which-key-scoped-replacement "evil-window-prev" "prev window")
   "k" (+which-key-scoped-replacement "evil-window-up" "go up")
   "j" (+which-key-scoped-replacement "evil-window-down" "go down")
   "C-<right>" "move right" "C-<left>" "move left"
   "C-<up>" "move up" "C-<down>" "move down"
   "C-_" "set height" "C-x" "exchange window" "C-S-w" "swap window (ace)"
   "C-S-s" "split window" "C-s" "split window" "C-S-r" "rotate up"
   "C-S-l" "move far right" "C-S-k" "move very top"
   "C-S-j" "move very bottom" "C-S-h" "move far left"
   "C-l" "go right" "C-j" "go down" "C-h" "go left" "C-c" "delete (ace)"))
