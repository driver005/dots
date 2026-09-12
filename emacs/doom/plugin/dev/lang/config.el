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
