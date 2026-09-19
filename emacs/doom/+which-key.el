;;; -*- lexical-binding: t; -*-
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
(after! which-key
  (which-key-add-key-based-replacements
   "w m v" "maximize vertically" "w m s" "maximize horizontally"
   "h C-s" "search help topics" "h K" "key node"
   "h L" "language environment" "h b i" "minor mode keymap"
   "h M" "active mode" "h C-l" "language environment"))
(defconst +which-key-desc-overrides
  (+which-key-scoped-replacements
   '(
     ("vertico-repeat" . "Repeat search")
     ("evil-switch-to-windows-last-buffer" . "Alt buffer")
     ("doom/toggle-scratch-buffer" . "Scratch toggle")
     ("+popup/toggle" . "Toggle popup")
     ("+default/search-project-for-symbol-at-point" . "Project symbol")
     ("persp-switch-to-buffer" . "Workspace buffer")
     ("bookmark-jump" . "Go bookmark")
     ("projectile-find-file" . "Project file")
     ("+workspace/display" . "Tab bar")
     ("+workspace/other" . "Alt workspace")
     ("+workspace/new-named" . "Named workspace")
     ("+workspace/load" . "Load workspace")
     ("+workspace/save" . "Save workspace")
     ("+workspace/kill" . "Kill workspace")
     ("+workspace/delete" . "Delete workspace")
     ("+workspace/restore-last-session" . "Restore session")
     ("+workspace/switch-to-0" . "Workspace 1")
     ("+workspace/switch-to-1" . "Workspace 2")
     ("+workspace/switch-to-2" . "Workspace 3")
     ("+workspace/switch-to-3" . "Workspace 4")
     ("+workspace/switch-to-4" . "Workspace 5")
     ("+workspace/switch-to-5" . "Workspace 6")
     ("+workspace/switch-to-6" . "Workspace 7")
     ("+workspace/switch-to-7" . "Workspace 8")
     ("+workspace/switch-to-8" . "Workspace 9")
     ("+workspace/switch-to-final" . "Last workspace")
     ("doom/kill-buried-buffers" . "Kill buried")
     ("evil-write-all" . "Save all")
     ("doom/kill-other-buffers" . "Kill others")
     ("evil-buffer-new" . "New buffer")
     ("doom/switch-to-scratch-buffer" . "Scratch buffer")
     ("doom/open-scratch-buffer" . "Scratch popup")
     ("doom/sudo-save-buffer" . "Sudo buffer")
     ("clone-indirect-buffer-other-window" . "Clone elsewhere")
     ("eglot-code-actions" . "Code action")
     ("+eval/buffer-or-region-in-repl" . "Send REPL")
     ("+eval:replace-region" . "Eval replace")
     ("doom/delete-trailing-newlines" . "Trim newlines")
     ("delete-trailing-whitespace" . "Trim whitespace")
     ("+lookup/type-definition" . "Type definition")
     ("+lookup/documentation" . "Go docs")
     ("+lookup/references" . "Go references")
     ("+lookup/definition" . "Go definition")
     ("eglot-find-implementation" . "Go implementation")
     ("+default/yank-buffer-path-relative-to-project" . "Relative path")
     ("doom/find-file-in-private-config" . "Private file")
     ("+default/find-file-under-here" . "Find here")
     ("doom/find-file-in-emacsd" . "Emacs.d file")
     ("+default/yank-buffer-path" . "Yank path")
     ("doom/sudo-this-file" . "Sudo file")
     ("doom/sudo-find-file" . "Sudo find")
     ("write-file" . "Save as")
     ("doom/open-private-config" . "Browse config")
     ("doom/delete-this-file" . "Delete file")
     ("doom/copy-this-file" . "Copy file")
     ("+default/insert-file-path" . "File name")
     ("+vc/git-link-kill" . "Copy remote")
     ("+vc/git-link-kill-homepage" . "Copy homepage")
     ("git-timemachine-toggle" . "Time machine")
     ("+vc-gutter/save-and-revert-hunk" . "Revert hunk")
     ("+vc-gutter/stage-hunk" . "Stage hunk")
     ("+vc-gutter/next-hunk" . "Next hunk")
     ("+vc-gutter/previous-hunk" . "Prev hunk")
     ("magit-file-dispatch" . "File dispatch")
     ("magit-branch-checkout" . "Switch branch")
     ("magit-status-here" . "Status here")
     ("magit-file-delete" . "Delete file")
     ("magit-log-buffer-file" . "Buffer log")
     ("magit-file-stage" . "Stage file")
     ("magit-file-unstage" . "Unstage file")
     ("magit-find-git-config-file" . "Find gitconfig")
     ("forge-visit-pullreq" . "Find PR")
     ("+vc/git-link" . "Browse link")
     ("forge-browse-issue" . "Browse issue")
     ("forge-browse-pullreq" . "Browse PR")
     ("forge-browse-pullreqs" . "Browse PRs")
     ("forge-list-pullreqs" . "List PRs")
     ("evil-show-registers" . "From register")
     ("crdt-copy-url" . "Copy URL")
     ("crdt-switch-to-buffer" . "Shared buffer")
     ("crdt-goto-prev-user" . "Prev cursor")
     ("crdt-goto-next-user" . "Next cursor")
     ("crdt-stop-share-buffer" . "Stop sharing")
     ("crdt-goto-user" . "User cursor")
     ("crdt-connect" . "Connect session")
     ("crdt-list-users" . "List users")
     ("crdt-share-buffer" . "Share buffer")
     ("crdt-list-buffers" . "List buffers")
     ("crdt-follow-user" . "Follow cursor")
     ("crdt-disconnect" . "Disconnect session")
     ("crdt-stop-follow" . "Unfollow user")
     ("crdt-stop-session" . "Stop session")
     ("crdt-kill-user" . "Kick user")
     ("+org/export-to-clipboard-as-rich-text" . "Export RTF")
     ("+org/export-to-clipboard" . "Export clipboard")
     ("+default/org-notes-headlines" . "Agenda headlines")
     ("+default/find-in-notes" . "Notes file")
     ("+default/search-notes-for-symbol-at-point" . "Notes symbol")
     ("org-store-link" . "Store link")
     ("org-clock-cancel" . "Cancel clock")
     ("+org/toggle-last-clock" . "Toggle clock")
     ("treemacs-find-file" . "Sidebar file")
     ("+eval/open-repl-same-window" . "REPL here")
     ("+debugger/start" . "Start debugger")
     ("+ghostel/here" . "Ghostel here")
     ("+ghostel/toggle" . "Ghostel toggle")
     ("gptel" . "Gptel chat")
     ("gptel-add" . "Add text")
     ("gptel-add-file" . "Add file")
     ("+llm/open-in-same-window" . "Gptel here")
     ("+omniroute/chat" . "OmniRoute chat")
     ("+omniroute/popup" . "OmniRoute popup")
     ("gptel-send" . "Send gptel")
     ("gptel-rewrite" . "Rewrite region")
     ("gptel-menu" . "Gptel menu")
     ("gptel-org-set-topic" . "Set topic")
     ("gptel-org-set-properties" . "Set properties")
     ("doom/find-file-in-other-project" . "Other project")
     ("projectile-run-async-shell-command-in-root" . "Async cmd")
     ("projectile-run-shell-command-in-root" . "Run cmd")
     ("doom/switch-to-project-scratch-buffer" . "Scratch buffer")
     ("projectile-recentf" . "Recent files")
     ("+default/discover-projects" . "Discover projects")
     ("projectile-switch-to-buffer" . "Project buffer")
     ("doom/toggle-project-scratch-buffer" . "Scratch toggle")
     ("projectile-save-project-buffers" . "Save files")
     ("find-sibling-file" . "Sibling file")
     ("projectile-kill-buffers" . "Kill buffers")
     ("projectile-invalidate-cache" . "Clear cache")
     ("projectile-edit-dir-locals" . "Edit locals")
     ("projectile-remove-known-project" . "Forget project")
     ("projectile-repeat-last-command" . "Repeat command")
     ("projectile-compile-project" . "Project compile")
     ("projectile-add-known-project" . "Add project")
     ("doom/browse-in-other-project" . "Browse elsewhere")
     ("doom/load-session" . "Restore file")
     ("doom/save-session" . "Save file")
     ("doom/quicksave-session" . "Quick save")
     ("save-buffers-kill-emacs" . "Kill daemon")
     ("doom/quickload-session" . "Restore last")
     ("+default/restart-server" . "Restart server")
     ("evil-quit-all-with-error-code" . "Force quit")
     ("+lookup/in-all-docsets" . "All docsets")
     ("+lookup/in-docsets" . "Local docsets")
     ("+lookup/online-select" . "Prompted lookup")
     ("+vertico/search-symbol-at-point" . "Search symbol")
     ("link-hint-open-link" . "Link hint")
     ("evil-show-marks" . "Go mark")
     ("+default/search-other-project" . "Other project")
     ("+lookup/online" . "Online lookup")
     ("ffap-menu" . "Go link")
     ("consult-imenu-multi" . "Buffer symbols")
     ("imenu" . "Go symbol")
     ("+default/search-other-cwd" . "Other directory")
     ("+default/search-cwd" . "Current dir")
     ("diff-hl-mode" . "Git Gutter")
     ("+zen/toggle-fullscreen" . "Zen fullscreen")
     ("visual-line-mode" . "Line wrap")
     ("global-display-fill-column-indicator-mode" . "Column indicator")
     ("+cc/eglot-ccls-inheritance-hierarchy" . "Type hierarchy"))))
(defun +which-key-desc-override-or-cleanup (key-binding)
  (let ((replaced (funcall +which-key-desc-overrides key-binding)))
    (if (equal replaced key-binding)
        (+which-key-generic-cleanup key-binding)
      replaced)))
(with-eval-after-load 'which-key
  (setq which-key-replacement-alist
        (cons (cons '(nil) #'+which-key-desc-override-or-cleanup)
              (delete (cons '(nil) #'+which-key-generic-cleanup)
                      which-key-replacement-alist))))
(map! :leader
      (:prefix-map ("b" . "buffer")
       :desc "Kill all" "K" #'doom/kill-all-buffers)
      (:prefix-map ("i" . "insert")
       :desc "File path" "F" (cmd!! #'+default/insert-file-path t)
       :desc "Ex path" "p" (cmd! (evil-ex "r!echo ")))
      (:prefix-map ("q" . "quit/session")
       :desc "Clear frame" "F" #'doom/kill-all-buffers)
      (:prefix-map ("s" . "search")
       :desc "All buffers" "B" (cmd!! #'consult-line-multi 'all-buffers)))
