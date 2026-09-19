;;; $DOOMDIR/init.el -*- lexical-binding: t; -*-

(when (display-graphic-p)
  (let ((shell-path (shell-command-to-string "$SHELL -lc 'printf %s \"$PATH\"'")))
    (unless (string-empty-p shell-path)
      (setenv "PATH" shell-path)
      (setq exec-path (split-string shell-path path-separator)))))

(setq doom-module-load-path
      (list (expand-file-name "plugin/ai" doom-user-dir)
            (file-name-concat doom-emacs-dir "modules")
            (file-name-concat doom-emacs-dir "sources/doom+/modules")))

(doom! :input
       ;;bidi              ; (tfel ot) thgir etirw uoy gnipleh
       ;;chinese
       ;;japanese
       ;;layout            ; auie,ctsrnm is the superior home row

       :completion
       ;;company           ; the ultimate code completion backend
       (corfu +orderless +icons +dabbrev)  ; complete with cap(f), cape and a flying feather!
       ;;helm              ; the *other* search engine for love and life
       ;;ido               ; the other *other* search engine...
       ;;ivy               ; a search engine for love and life
       (vertico +icons)           ; the search engine of the future

       :ui
       ;;deft              ; notational velocity for Emacs
       doom              ; what makes DOOM look the way it does
       ;;dashboard         ; a nifty splash screen for Emacs
       ;;doom-quit         ; DOOM quit-message prompts when you quit Emacs
       (emoji +unicode +github +ascii)  ; 🙂
       hl-todo           ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
       ;;indent-guides     ; highlighted indent columns
       ;;ligatures         ; ligatures and symbols to make your code pretty again
       ;;minimap           ; show a map of the code on the side
       (modeline +light) ; snazzy, Atom-inspired modeline, plus API
       ;;nav-flash         ; blink cursor line after big motions
       ;;neotree           ; a project drawer, like NERDTree for vim
       ophints           ; highlight the region an operation acts on
       ;;(popup +defaults)   ; tame sudden yet inevitable temporary windows
       ;;smooth-scroll     ; So smooth you won't believe it's not butter
       ;;tabs              ; a tab bar for Emacs
       treemacs          ; TODO: to be removed! (a project drawer, like neotree but cooler)
       ;;unicode           ; extended unicode support for various languages
       (vc-gutter +pretty) ; vcs diff in the fringe
       ;;vi-tilde-fringe   ; fringe tildes to mark beyond EOB
       ;;window-select     ; visually switch windows
       ;;workspaces        ; tab emulation, persistence & separate workspaces
       ;;(zen +focus)      ; distraction-free coding or writing

       :editor
       (evil +everywhere); come to the dark side, we have cookies
       ;;file-templates    ; auto-snippets for empty files
       ;;fold              ; (nigh) universal code folding
       (format +onsave)  ; automated prettiness
       ;;god               ; run Emacs commands without modifier keys
       ;;lispy             ; vim for lisp, for people who don't like vim
       ;;multiple-cursors  ; editing in many places at once
       ;;objed             ; text object editing for the innocent
       ;;parinfer          ; turn lisp into python, sort of
       rotate-text       ; cycle region at point between text candidates
       snippets          ; my elves. They type so I don't have to
       (whitespace +guess +trim)  ; a butler for your whitespace
       ;;word-wrap         ; soft wrapping with language-aware indent

       :emacs
       (dired +icons)    ; making dired pretty [functional]
       electric          ; smarter, keyword-based electric-indent
       ;;eww               ; the internet is gross
       ;;(ibuffer +icons)  ; interactive buffer management
       tramp             ; remote files at your arthritic fingertips
       undo              ; persistent, smarter undo for your inevitable mistakes
       vc                ; version-control and Emacs, sitting in a tree

       :term
       ;;eshell            ; the elisp shell that works everywhere
       ;;shell             ; simple shell REPL for Emacs
       ;;term              ; basic terminal emulator for Emacs
       ;;vterm             ; almost the best terminal emulation in Emacs
       (ghostel +everywhere) ; the best terminal emulation in Emacs

       :checkers
       (syntax +icons)     ; tasing you for every semicolon you forget
       (spell +flyspell +enchant +everywhere) ; tasing you for misspelling mispelling
       grammar           ; tasing grammar mistake every you make

       :tools
       ;;ansible
       ;;biblio            ; Writes a PhD for you (citation needed)
       ;;collab            ; buffers with friends
       debugger          ; stepping through code, to help you add bugs
       ;;direnv
       ;;(docker +lsp +tree-sitter)
       ;;editorconfig      ; let someone else argue about tabs vs spaces
       ;;ein               ; tame Jupyter notebooks with emacs
       ;;(eval +overlay)     ; run code, run (also, repls)
       (lookup +dictionary +offline) ; navigate your code and its documentation
       llm               ; when I said you needed friends, I didn't mean...
       (lsp +booster) ; M-x vscode
       (magit +forge)    ; a git porcelain for Emacs
       ;;make              ; run make tasks from Emacs
       ;;(pass +auth)      ; password manager for nerds
       pdf               ; pdf enhancements
       ;;(terraform +lsp)  ; infrastructure as code
       ;;tmux              ; an API for interacting with tmux
       tree-sitter       ; syntax and parsing, sitting in a tree...
       ;;upload            ; map local to remote projects via ssh/ftp

       :os
       (:if (featurep :system 'macos) macos)  ; improve compatibility with macOS
       ;;tty               ; improve the terminal Emacs experience
)

(load! "profile/default")

(doom! :email

       ;;(mu4e +org +gmail)
       notmuch
       ;;(wanderlust +gmail)

       :app
       calendar
       ;;emms
       ;;everywhere        ; *leave* Emacs!? You must be joking
       ;;irc               ; how neckbeards socialize
       ;;(rss +org)        ; emacs as an RSS reader

       :config
       ;;literate
       (default +bindings +smartparens +gnupg)

       ;; PRIVATE AI MODULES
       ai/agent
       ai/agent-shell-dashboard
       ai/gptel
       ai/tabby
       ai/octocode)

