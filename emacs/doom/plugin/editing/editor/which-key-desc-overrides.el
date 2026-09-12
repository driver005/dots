;;; plugin/editing/editor/which-key-desc-overrides.el -*- lexical-binding: t; -*-

;; Which-key description overrides for vendored Doom `SPC'-leader
;; bindings - re-declaring the same key + same command with a shorter
;; `:desc' via `map!'/general.el's ordinary keymap merge. Not a behavior
;; change. Safe by construction: a `map!' `:desc'-carrying leaf binding is
;; a literal (DESC . COMMAND) pair stored at one exact path inside
;; `doom-leader-map''s own tree via plain keymap lookup - NOT
;; `which-key-replacement-alist' regex matching (that's the mechanism
;; which-key.el's evil-state entries use, and which needed the guard-
;; function fix over there). A binding at one exact key path can't leak
;; into another keymap, so no guard is needed here.
;;
;; Two policies applied throughout: (1) only entries confirmed live/active
;; in THIS config are covered (checked via `lookup-key' against the
;; running session) - anything gated behind a module/flag this config
;; doesn't enable is dead code here and was skipped (e.g. :config
;; literate's "SPC f h", the `:ui workspaces'-guarded "SPC c J" which
;; `:tools lsp +eglot' has no equivalent for, or the lsp-mode-only "SPC c"
;; branches since this config uses +eglot). (2) target length is ~2 words
;; everywhere it doesn't lose meaning - a few multi-related-entry families
;; and two explicit safety-relevant commands were deliberately kept
;; longer, noted inline where that happens.
;;
;; NOT covered here (deferred, not forgotten): a handful of *prefix group
;; title* renames (e.g. "SPC g o" group is named "open in browser", 3
;; words) - `:prefix' group names use a different which-key mechanism than
;; leaf `:desc' strings and weren't touched in this pass.

(map! :leader
      :desc "Repeat search" "'" #'vertico-repeat
      :desc "Alt buffer" "`" #'evil-switch-to-windows-last-buffer
      :desc "Scratch toggle" "x" #'doom/toggle-scratch-buffer
      :desc "Toggle popup" "~" #'+popup/toggle
      :desc "Project symbol" "*" #'+default/search-project-for-symbol-at-point
      :desc "Workspace buffer" "," #'persp-switch-to-buffer
      :desc "Go bookmark" "RET" #'bookmark-jump
      :desc "Project file" "SPC" #'projectile-find-file

      (:prefix-map ("TAB" . "workspace")
       :desc "Tab bar" "TAB" #'+workspace/display
       :desc "Alt workspace" "`" #'+workspace/other
       :desc "Named workspace" "N" #'+workspace/new-named
       :desc "Load workspace" "l" #'+workspace/load
       :desc "Save workspace" "s" #'+workspace/save
       :desc "Kill workspace" "d" #'+workspace/kill
       :desc "Delete workspace" "D" #'+workspace/delete
       :desc "Restore session" "R" #'+workspace/restore-last-session
       :desc "Workspace 1" "1" #'+workspace/switch-to-0
       :desc "Workspace 2" "2" #'+workspace/switch-to-1
       :desc "Workspace 3" "3" #'+workspace/switch-to-2
       :desc "Workspace 4" "4" #'+workspace/switch-to-3
       :desc "Workspace 5" "5" #'+workspace/switch-to-4
       :desc "Workspace 6" "6" #'+workspace/switch-to-5
       :desc "Workspace 7" "7" #'+workspace/switch-to-6
       :desc "Workspace 8" "8" #'+workspace/switch-to-7
       :desc "Workspace 9" "9" #'+workspace/switch-to-8
       :desc "Last workspace" "0" #'+workspace/switch-to-final)

      (:prefix-map ("b" . "buffer")
       :desc "Kill buried" "Z" #'doom/kill-buried-buffers
       :desc "Save all" "S" #'evil-write-all
       :desc "Kill others" "O" #'doom/kill-other-buffers
       :desc "New buffer" "N" #'evil-buffer-new
       :desc "Kill all" "K" #'doom/kill-all-buffers
       :desc "Workspace buffer" "b" #'persp-switch-to-buffer
       :desc "Scratch buffer" "X" #'doom/switch-to-scratch-buffer
       :desc "Scratch popup" "x" #'doom/open-scratch-buffer
       :desc "Sudo buffer" "u" #'doom/sudo-save-buffer
       :desc "Alt buffer" "l" #'evil-switch-to-windows-last-buffer
       :desc "Clone elsewhere" "C" #'clone-indirect-buffer-other-window)

      (:prefix-map ("c" . "code")
       :desc "Code action" "a" #'eglot-code-actions
       :desc "Send REPL" "s" #'+eval/buffer-or-region-in-repl
       :desc "Eval replace" "E" #'+eval:replace-region
       :desc "Trim newlines" "W" #'doom/delete-trailing-newlines
       :desc "Trim whitespace" "w" #'delete-trailing-whitespace
       :desc "Type definition" "t" #'+lookup/type-definition
       :desc "Go docs" "k" #'+lookup/documentation
       :desc "Go references" "D" #'+lookup/references
       :desc "Go definition" "d" #'+lookup/definition
       :desc "Go symbol" "j" #'consult-eglot-symbols)

      (:prefix-map ("f" . "file")
       :desc "Relative path" "Y" #'+default/yank-buffer-path-relative-to-project
       :desc "Private file" "p" #'doom/find-file-in-private-config
       :desc "Find here" "F" #'+default/find-file-under-here
       :desc "Emacs.d file" "e" #'doom/find-file-in-emacsd
       :desc "Yank path" "y" #'+default/yank-buffer-path
       :desc "Sudo file" "U" #'doom/sudo-this-file
       :desc "Sudo find" "u" #'doom/sudo-find-file
       :desc "Save as" "S" #'write-file
       :desc "Browse config" "P" #'doom/open-private-config
       :desc "Delete file" "D" #'doom/delete-this-file
       :desc "Copy file" "C" #'doom/copy-this-file)

      (:prefix-map ("g" . "git")
       :desc "Copy remote" "y" #'+vc/git-link-kill
       :desc "Copy homepage" "Y" #'+vc/git-link-kill-homepage
       :desc "Time machine" "t" #'git-timemachine-toggle
       :desc "Revert hunk" "r" #'+vc-gutter/save-and-revert-hunk
       :desc "Stage hunk" "s" #'+vc-gutter/stage-hunk
       :desc "Next hunk" "]" #'+vc-gutter/next-hunk
       :desc "Prev hunk" "[" #'+vc-gutter/previous-hunk
       :desc "File dispatch" "." #'magit-file-dispatch
       :desc "Switch branch" "b" #'magit-branch-checkout
       :desc "Status here" "G" #'magit-status-here
       :desc "Delete file" "D" #'magit-file-delete
       :desc "Buffer log" "L" #'magit-log-buffer-file
       :desc "Stage file" "S" #'magit-file-stage
       :desc "Unstage file" "U" #'magit-file-unstage
       (:prefix ("f" . "find")
        :desc "Find gitconfig" "g" #'magit-find-git-config-file
        :desc "Find PR" "p" #'forge-visit-pullreq)
       (:prefix ("o" . "open in browser")
        :desc "Browse link" "o" #'+vc/git-link
        :desc "Browse issue" "i" #'forge-browse-issue
        :desc "Browse PR" "p" #'forge-browse-pullreq
        :desc "Browse PRs" "P" #'forge-browse-pullreqs)
       (:prefix ("l" . "list")
        :desc "List PRs" "p" #'forge-list-pullreqs))

      (:prefix-map ("i" . "insert")
       :desc "File path" "F" (cmd!! #'+default/insert-file-path t)
       :desc "File name" "f" #'+default/insert-file-path
       :desc "Ex path" "p" (cmd! (evil-ex "r!echo "))
       :desc "From register" "r" #'evil-show-registers)

      (:prefix-map ("l" . "live share/collab")
       :desc "Copy URL" "y" #'crdt-copy-url
       :desc "Shared buffer" "b" #'crdt-switch-to-buffer
       :desc "Prev cursor" "[" #'crdt-goto-prev-user
       :desc "Next cursor" "]" #'crdt-goto-next-user
       :desc "Stop sharing" "S" #'crdt-stop-share-buffer
       :desc "User cursor" "g" #'crdt-goto-user
       :desc "Connect session" "c" #'crdt-connect
       :desc "List users" "u" #'crdt-list-users
       :desc "Share buffer" "s" #'crdt-share-buffer
       :desc "List buffers" "i" #'crdt-list-buffers
       :desc "Follow cursor" "f" #'crdt-follow-user
       :desc "Disconnect session" "d" #'crdt-disconnect
       :desc "Unfollow user" "F" #'crdt-stop-follow
       ;; Category C: user chose 2 words, dropping the host-only warning.
       :desc "Stop session" "x" #'crdt-stop-session
       :desc "Kick user" "k" #'crdt-kill-user)

      (:prefix-map ("n" . "notes")
       :desc "Export RTF" "Y" #'+org/export-to-clipboard-as-rich-text
       :desc "Export clipboard" "y" #'+org/export-to-clipboard
       :desc "Agenda headlines" "S" #'+default/org-notes-headlines
       :desc "Notes file" "f" #'+default/find-in-notes
       :desc "Notes symbol" "*" #'+default/search-notes-for-symbol-at-point
       :desc "Store link" "l" #'org-store-link
       :desc "Cancel clock" "C" #'org-clock-cancel
       :desc "Toggle clock" "c" #'+org/toggle-last-clock)

      (:prefix-map ("o" . "open")
       :desc "Sidebar file" "P" #'treemacs-find-file
       :desc "REPL here" "R" #'+eval/open-repl-same-window
       :desc "Start debugger" "d" #'+debugger/start
       :desc "Ghostel here" "T" #'+ghostel/here
       :desc "Ghostel toggle" "t" #'+ghostel/toggle
       (:prefix ("l" . "llm")
        :desc "Add text" "a" #'gptel-add
        :desc "Add file" "f" #'gptel-add-file
        :desc "Gptel here" "L" #'+llm/open-in-same-window
        :desc "Send gptel" "s" #'gptel-send
        :desc "Gptel menu" "m" #'gptel-menu
        :desc "Set topic" "o" #'gptel-org-set-topic
        :desc "Set properties" "O" #'gptel-org-set-properties))

      (:prefix-map ("p" . "project")
       :desc "Other project" "F" #'doom/find-file-in-other-project
       :desc "Async cmd" "&" #'projectile-run-async-shell-command-in-root
       :desc "Run cmd" "!" #'projectile-run-shell-command-in-root
       :desc "Scratch buffer" "X" #'doom/switch-to-project-scratch-buffer
       :desc "Recent files" "r" #'projectile-recentf
       :desc "Project file" "f" #'projectile-find-file
       :desc "Discover projects" "D" #'+default/discover-projects
       :desc "Project buffer" "b" #'projectile-switch-to-buffer
       :desc "Scratch toggle" "x" #'doom/toggle-project-scratch-buffer
       :desc "Save files" "s" #'projectile-save-project-buffers
       :desc "Sibling file" "o" #'find-sibling-file
       :desc "Kill buffers" "k" #'projectile-kill-buffers
       :desc "Clear cache" "i" #'projectile-invalidate-cache
       :desc "Edit locals" "e" #'projectile-edit-dir-locals
       :desc "Forget project" "d" #'projectile-remove-known-project
       :desc "Repeat command" "C" #'projectile-repeat-last-command
       :desc "Project compile" "c" #'projectile-compile-project
       :desc "Add project" "a" #'projectile-add-known-project
       :desc "Browse elsewhere" ">" #'doom/browse-in-other-project)

      (:prefix-map ("q" . "quit/session")
       :desc "Restore file" "L" #'doom/load-session
       :desc "Save file" "S" #'doom/save-session
       :desc "Quick save" "s" #'doom/quicksave-session
       :desc "Kill daemon" "K" #'save-buffers-kill-emacs
       :desc "Restore last" "l" #'doom/quickload-session
       :desc "Clear frame" "F" #'doom/kill-all-buffers
       :desc "Restart server" "d" #'+default/restart-server
       ;; Category C: user chose 2 words over the "without saving" warning.
       :desc "Force quit" "Q" #'evil-quit-all-with-error-code)

      (:prefix-map ("s" . "search")
       :desc "All docsets" "K" #'+lookup/in-all-docsets
       :desc "Local docsets" "k" #'+lookup/in-docsets
       :desc "Prompted lookup" "O" #'+lookup/online-select
       :desc "Search symbol" "S" #'+vertico/search-symbol-at-point
       :desc "Link hint" "l" #'link-hint-open-link
       :desc "All buffers" "B" (cmd!! #'consult-line-multi 'all-buffers)
       :desc "Go mark" "r" #'evil-show-marks
       :desc "Other project" "P" #'+default/search-other-project
       :desc "Online lookup" "o" #'+lookup/online
       :desc "Go bookmark" "m" #'bookmark-jump
       :desc "Go link" "L" #'ffap-menu
       :desc "Buffer symbols" "I" #'consult-imenu-multi
       :desc "Go symbol" "i" #'imenu
       :desc "Other directory" "D" #'+default/search-other-cwd
       :desc "Current dir" "d" #'+default/search-cwd)

      (:prefix-map ("t" . "toggle")
       :desc "Git Gutter" "d" #'diff-hl-mode
       :desc "Zen fullscreen" "Z" #'+zen/toggle-fullscreen
       :desc "Line wrap" "w" #'visual-line-mode
       :desc "Column indicator" "c" #'global-display-fill-column-indicator-mode))

;; Mode-local (SPC m, not the global leader) - same :localleader/:map/:after
;; guard as the vendored binding, just a shorter :desc.
(map! :localleader
      :after cc-mode
      :map c++-mode-map
      :desc "Type hierarchy" "ct" #'+cc/eglot-ccls-inheritance-hierarchy)
