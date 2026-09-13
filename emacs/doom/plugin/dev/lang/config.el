;;; plugin/dev/lang/config.el -*- lexical-binding: t; -*-

;; `:lang cc' has no idea C++20 module interface units exist - only `.cl'
;; (OpenCL) gets a special extension mapping in its own autoload.el.
;; `.cppm' (the common convention), MSVC's `.ixx', and the less common
;; `.mpp'/`.cxxm'/`.mxx' variants all need to land in `c++-mode' by hand.
;; Bound to plain `c++-mode', not `c++-ts-mode' directly - Doom's own
;; `set-tree-sitter!' call for c++-mode (in the cc module itself) already
;; remaps to the tree-sitter mode automatically when available.
(dolist (ext '("cppm" "ixx" "mpp" "cxxm" "mxx"))
  (add-to-list 'auto-mode-alist (cons (concat "\\." ext "\\'") 'c++-mode)))

;; nerd-icons has its own separate, hardcoded extension->icon table
;; (`nerd-icons-extension-icon-alist') - it already knows cpp/cc/cxx/hpp/hxx
;; but has never heard of the module-unit extensions above, so those files
;; opened correctly as c++-mode but rendered with a generic/unknown icon in
;; dired/treemacs. Same icon+face nerd-icons already uses for "cpp".
(after! nerd-icons
  (dolist (ext '("cppm" "ixx" "mpp" "cxxm" "mxx"))
    (add-to-list 'nerd-icons-extension-icon-alist
                 `(,ext nerd-icons-sucicon "nf-custom-cpp" :face nerd-icons-blue))))

;; Format BUILD/WORKSPACE/*.bzl files with `buildifier' on save (needs the
;; `buildifier' binary - see install-requirements.sh).
(add-hook! 'bazel-mode-hook
  (add-hook 'before-save-hook #'bazel-buildifier nil t))

;; Markdown Tree-sitter: remap markdown-mode and gfm-mode to native Emacs 31 markdown-ts-mode
(when (and (fboundp 'treesit-available-p) (treesit-available-p))
  (add-to-list 'major-mode-remap-alist '(markdown-mode . markdown-ts-mode))
  (add-to-list 'major-mode-remap-alist '(gfm-mode . markdown-ts-mode)))

(after! markdown-ts-mode
  ;; Ensure all localleader bindings work seamlessly in markdown-ts-mode (Doom #8777)
  (map! :map markdown-ts-mode-map
        :localleader
        "'" #'markdown-edit-code-block
        "o" #'markdown-open
        :desc "Preview in Doom" "p" #'markdown-preview
        :desc "Live preview in Doom" "P" #'markdown-live-preview-mode
        "e" #'markdown-export
        (:prefix ("i" . "insert")
         :desc "Table Of Content"  "T" #'markdown-toc-generate-toc
         :desc "Image"             "i" #'markdown-insert-image
         :desc "Link"              "l" #'markdown-insert-link
         :desc "<hr>"              "-" #'markdown-insert-hr
         :desc "Heading 1"         "1" #'markdown-insert-header-atx-1
         :desc "Heading 2"         "2" #'markdown-insert-header-atx-2
         :desc "Heading 3"         "3" #'markdown-insert-header-atx-3
         :desc "Heading 4"         "4" #'markdown-insert-header-atx-4
         :desc "Heading 5"         "5" #'markdown-insert-header-atx-5
         :desc "Heading 6"         "6" #'markdown-insert-header-atx-6
         :desc "Code block"        "C" #'markdown-insert-gfm-code-block
         :desc "Pre region"        "P" #'markdown-pre-region
         :desc "Blockquote region" "Q" #'markdown-blockquote-region
         :desc "Checkbox"          "[" #'markdown-insert-gfm-checkbox
         :desc "Bold"              "b" #'markdown-insert-bold
         :desc "Inline code"       "c" #'markdown-insert-code
         :desc "Italic"            "e" #'markdown-insert-italic
         :desc "Footnote"          "f" #'markdown-insert-footnote
         :desc "Header dwim"       "h" #'markdown-insert-header-dwim
         :desc "Italic"            "i" #'markdown-insert-italic
         :desc "Kbd"               "k" #'markdown-insert-kbd
         :desc "Pre"               "p" #'markdown-insert-pre
         :desc "New blockquote"    "q" #'markdown-insert-blockquote
         :desc "Strike through"    "s" #'markdown-insert-strike-through
         :desc "Table"             "t" #'markdown-insert-table
         :desc "Wiki link"         "w" #'markdown-insert-wiki-link)
        (:prefix ("t" . "toggle")
         :desc "Inline LaTeX"      "e" #'markdown-toggle-math
         :desc "Inline images"     "i" #'markdown-ts-toggle-inline-images
         :desc "Markup hiding"     "m" #'markdown-ts-toggle-hide-markup
         :desc "Wiki links"        "w" #'markdown-toggle-wiki-links
         :desc "GFM checkbox"      "x" #'markdown-ts-toggle-checkbox)))

;; Inhibit emojify-mode in markdown buffers to avoid overlay redisplay overhead
(after! emojify
  (dolist (mode '(markdown-mode markdown-ts-mode gfm-mode))
    (add-to-list 'emojify-inhibit-major-modes mode)))

(add-hook! '(markdown-ts-mode-hook markdown-mode-hook gfm-mode-hook) :append
  (when (bound-and-true-p emojify-mode)
    (emojify-mode -1)))

;; Markdown In-Doom Preview:
;; Route markdown previews to EWW inside Emacs (side-by-side split) instead of an external browser
(after! markdown-mode
  (setq markdown-split-window-direction 'right)
  (set-popup-rule! "^\\*eww" :side 'right :size 0.5 :quit t :select t)
  (defadvice! +markdown-preview-in-doom-a (fn &rest args)
    "Force `markdown-preview' to open in Doom via `eww-browse-url'."
    :around #'markdown-preview
    (let ((browse-url-browser-function #'eww-browse-url))
      (apply fn args)))
  (map! :map markdown-mode-map
        :localleader
        :desc "Preview in Doom" "p" #'markdown-preview
        :desc "Live preview in Doom" "P" #'markdown-live-preview-mode))




