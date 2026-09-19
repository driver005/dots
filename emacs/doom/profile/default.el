;;; profile/default.el -*- lexical-binding: t; -*-

(doom! :lang
       ;;ada               ; In strong typing we (blindly) trust
       ;;(agda +local)     ; types of types of types of types...
       ;;beancount         ; mind the GAAP
       (cc +lsp +tree-sitter)         ; C > C++ == 1
       ;;clojure           ; java with a lisp
       ;;common-lisp       ; if you've seen one lisp, you've seen them all
       ;;coq               ; proofs-as-programs
       ;;crystal           ; ruby at the speed of c
       ;;csharp            ; unity, .NET, and mono shenanigans
       ;;data              ; config/data formats
       ;;(dart +flutter +lsp +tree-sitter) ; paint ui and not much else
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
       (go +lsp +tree-sitter)         ; the hipster dialect
       ;;(graphql +lsp)    ; Give queries a REST
       ;;(haskell +lsp)    ; a language that's lazier than I am
       ;;hy                ; readability of scheme w/ speed of python
       ;;idris             ; a language you can depend on
       (json +lsp)       ; At least it ain't XML
       ;;janet             ; Fun fact: Janet is me!
       (java +lsp)       ; the poster child for carpal tunnel syndrome
       (javascript +lsp +tree-sitter) ; all(hope(abandon(ye(who(enter(here))))))
       ;;julia             ; a better, faster MATLAB
       ;;kotlin            ; a better, slicker Java(Script)
       ;;latex             ; writing papers in Emacs has never been so fun
       ;;lean              ; for folks with too much to prove
       ;;ledger            ; be audit you can be
       ;;(lua +lsp)        ; one-based indices? one-based indices
       markdown          ; writing docs for people to ignore
       ;;nim               ; python + lisp at the speed of c
       ;;(nix +lsp)        ; I hereby declare "nix geht mehr!"
       ;;ocaml             ; an objective camel
       ;;odin              ; C, minus its footguns
       org               ; organize your plain life in plain text
       ;;php               ; perl's insecure younger brother
       ;;plantuml          ; diagrams for confusing people more
       ;;graphviz          ; diagrams for confusing yourself even more
       ;;(purescript +lsp) ; javascript, but functional
       (python +lsp +tree-sitter +uv +cython)     ; beautiful is better than ugly
       ;;qt                ; the 'cutest' gui framework ever
       ;;racket            ; a DSL for DSLs
       ;;raku              ; the artist formerly known as perl6
       ;;rest              ; Emacs as a REST client
       ;;rst               ; ReST in peace
       ;;(ruby +rails)     ; 1.step {|i| p "Ruby is #{i.even? ? 'love' : 'life'}"}
       (rust +lsp +tree-sitter)       ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
       ;;scad              ; trust the preview, regret the render
       ;;scala             ; java, but good
       ;;(scheme +guile)   ; a fully conniving family of lisps
       (sh +lsp)                ; she sells {ba,z,fi}sh shells on the C xor
       ;;sml
       ;;solidity          ; do you need a blockchain? No.
       ;;swift             ; who asked for emoji variables?
       ;;terra             ; Earth and Moon in alignment for performance.
       (web +lsp +tree-sitter)        ; the tubes
       (yaml +lsp)       ; JSON, but readable
       (zig +lsp +tree-sitter)        ; C, but simpler
)
