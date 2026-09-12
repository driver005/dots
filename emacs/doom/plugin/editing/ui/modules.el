(:ui
 ;;deft              ; notational velocity for Emacs
 doom              ; what makes DOOM look the way it does
 dashboard         ; a nifty splash screen for Emacs
 ;;doom-quit         ; DOOM quit-message prompts when you quit Emacs
 (emoji +unicode +github +ascii)  ; 🙂
 hl-todo           ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
 ;;indent-guides     ; highlighted indent columns
 ;;ligatures         ; ligatures and symbols to make your code pretty again
 ;;minimap           ; show a map of the code on the side
 modeline          ; snazzy, Atom-inspired modeline, plus API ;; other flags: +light (drops doom-modeline dependency, fixes perf issues, less featureful)
 ;;nav-flash         ; blink cursor line after big motions
 ;;neotree           ; a project drawer, like NERDTree for vim
 ophints           ; highlight the region an operation acts on
 (popup +defaults)   ; tame sudden yet inevitable temporary windows ;; other flags: +all (treat every *scratch*/space-prefixed buffer as a popup too)
 ;;smooth-scroll     ; So smooth you won't believe it's not butter
 tabs              ; a tab bar for Emacs
 treemacs          ; a project drawer, like neotree but cooler ;; other flags: +lsp (lsp-treemacs integration)
 ;;unicode           ; extended unicode support for various languages
 (vc-gutter +pretty) ; vcs diff in the fringe
 vi-tilde-fringe   ; fringe tildes to mark beyond EOB
 ;;window-select     ; visually switch windows
 workspaces        ; tab emulation, persistence & separate workspaces
 (zen +focus)      ; distraction-free coding or writing (focus dimming detached into its own `SPC t n' toggle - see plugin/editing/ui/zen.el)
 )
