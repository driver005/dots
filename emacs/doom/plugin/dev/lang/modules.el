(:lang
 ;;ada               ; In strong typing we (blindly) trust
 ;;(agda +local)     ; types of types of types of types...
 ;;beancount         ; mind the GAAP
 (cc +lsp)         ; C > C++ == 1 ;; other flags: +tree-sitter
 ;;clojure           ; java with a lisp
 common-lisp       ; if you've seen one lisp, you've seen them all ;; other flags: +tree-sitter (no +lsp - uses SLY/SLIME, not LSP)
 ;;coq               ; proofs-as-programs
 ;;crystal           ; ruby at the speed of c
 ;;csharp            ; unity, .NET, and mono shenanigans
 ;;data              ; config/data formats
 (dart +flutter +lsp) ; paint ui and not much else ;; other flags: +tree-sitter
 ;;dhall
 ;;elixir            ; erlang done right
 ;;elm               ; care for a cup of TEA?
 emacs-lisp        ; drown in parentheses
 ;;erlang            ; an elegant language for a more civilized age
 ;;ess               ; emacs speaks statistics
 ;;factor
 ;;faust             ; dsp, but you get to keep your soul
 ;;fortran           ; in FORTRAN, GOD is REAL (unless declared INTEGER)
 ;;fsharp            ; ML stands for Microsoft's Language
 ;;fstar             ; (dependent) types and (monadic) effects and Z3
 ;;gdscript          ; the language you waited for
 (go +lsp)         ; the hipster dialect ;; other flags: +tree-sitter
 (graphql +lsp)    ; Give queries a REST ;; other flags: +tree-sitter
 ;;(haskell +lsp)    ; a language that's lazier than I am
 ;;hy                ; readability of scheme w/ speed of python
 ;;idris             ; a language you can depend on
 (json +lsp)       ; At least it ain't XML ;; other flags: +tree-sitter
 ;;janet             ; Fun fact: Janet is me!
 (java +lsp)       ; the poster child for carpal tunnel syndrome ;; other flags: +tree-sitter
 (javascript +lsp) ; all(hope(abandon(ye(who(enter(here))))))  ;; other flags: +tree-sitter
 ;;julia             ; a better, faster MATLAB
 ;;kotlin            ; a better, slicker Java(Script)
 ;;latex             ; writing papers in Emacs has never been so fun
 ;;lean              ; for folks with too much to prove
 ;;ledger            ; be audit you can be
 (lua +lsp)        ; one-based indices? one-based indices ;; other flags: +fennel, +tree-sitter, +moonscript
 markdown          ; writing docs for people to ignore ;; other flags: +lsp, +grip, +tree-sitter
 nim               ; python + lisp at the speed of c
 (nix +lsp)        ; I hereby declare "nix geht mehr!" ;; other flags: +tree-sitter
 ;;ocaml             ; an objective camel
 ;;odin              ; C, minus its footguns
 org               ; organize your plain life in plain text ;; other flags: +dragndrop, +crypt, +gnuplot, +journal, +jupyter, +noter, +pandoc, +present, +pretty, +roam
 ;;php               ; perl's insecure younger brother
 ;;plantuml          ; diagrams for confusing people more
 ;;graphviz          ; diagrams for confusing yourself even more
 (purescript +lsp) ; javascript, but functional
 (python +lsp)     ; beautiful is better than ugly ;; other flags: +conda, +cython, +poetry, +pyenv, +pyright, +tree-sitter, +uv
 ;;qt                ; the 'cutest' gui framework ever
 ;;racket            ; a DSL for DSLs
 ;;raku              ; the artist formerly known as perl6
 rest              ; Emacs as a REST client ;; other flags: +jq (not LSP-related - needs the jq CLI)
 ;;rst               ; ReST in peace
 ;;(ruby +rails)     ; 1.step {|i| p "Ruby is #{i.even? ? 'love' : 'life'}"}
 (rust +lsp)       ; Fe2O3.unwrap().unwrap().unwrap().unwrap() ;; other flags: +tree-sitter
 ;;scad              ; trust the preview, regret the render
 ;;scala             ; java, but good
 ;;(scheme +guile)   ; a fully conniving family of lisps
 sh                ; she sells {ba,z,fi}sh shells on the C xor ;; other flags: +fish, +lsp, +powershell
 ;;sml
 solidity          ; do you need a blockchain? No.
 ;;swift             ; who asked for emoji variables?
 ;;terra             ; Earth and Moon in alignment for performance.
 (web +lsp)        ; the tubes ;; other flags: +tree-sitter
 (yaml +lsp)       ; JSON, but readable ;; other flags: +tree-sitter
 (zig +lsp)        ; C, but simpler ;; other flags: +tree-sitter
 )
