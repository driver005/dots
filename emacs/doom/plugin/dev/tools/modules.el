(:tools
 ;;ansible
 biblio            ; Writes a PhD for you (citation needed)
 collab            ; buffers with friends ;; other flags: +tunnel (Tox-based NAT traversal)
 debugger          ; stepping through code, to help you add bugs
 ;;direnv
 (docker +lsp +tree-sitter)
 ;;editorconfig      ; let someone else argue about tabs vs spaces
 ein               ; tame Jupyter notebooks with emacs
 (eval +overlay)     ; run code, run (also, repls)
 (lookup +dictionary +offline) ; navigate your code and its documentation ;; other flags: +docsets (macOS/Dash only), +yandex
 llm               ; when I said you needed friends, I didn't mean...
 (lsp +booster) ; M-x vscode ;; other flags: +eglot +peek (lsp-ui-peek for lookup)
 (magit +forge)    ; a git porcelain for Emacs
 make              ; run make tasks from Emacs
 (pass +auth)      ; password manager for nerds
 pdf               ; pdf enhancements
 (terraform +lsp)  ; infrastructure as code
 ;;tmux              ; an API for interacting with tmux
 tree-sitter       ; syntax and parsing, sitting in a tree... (required by docker +tree-sitter)
 ;;upload            ; map local to remote projects via ssh/ftp
 )
