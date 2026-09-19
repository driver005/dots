;;; langs.el -*- lexical-binding: t; -*-

(dolist (ext '("cppm" "ixx" "mpp" "cxxm" "mxx"))
  (add-to-list 'auto-mode-alist (cons (concat "\\." ext "\\'") 'c++-mode)))

(after! nerd-icons
  (dolist (ext '("cppm" "ixx" "mpp" "cxxm" "mxx"))
    (add-to-list 'nerd-icons-extension-icon-alist
                 `(,ext nerd-icons-sucicon "nf-custom-cpp" :face nerd-icons-blue))))

(defun +eglot-ensure-rass-presets ()
  (let ((preset-dir (expand-file-name "~/.config/rassumfrassum")))
    (unless (file-directory-p preset-dir)
      (make-directory preset-dir t)
      (with-temp-file (expand-file-name "python.py" preset-dir)
        (insert " \"\"\"Python multi-server: ty + ruff.\"\"\"\n"
                "def servers():\n"
                "    return [\n"
                "        {\"name\": \"ty\", \"command\": [\"ty\", \"server\"]},\n"
                "        {\"name\": \"ruff\", \"command\": [\"ruff\", \"server\"]},\n"
                "    ]\n"))
      (with-temp-file (expand-file-name "javascript.py" preset-dir)
        (insert " \"\"\"JS/TS multi-server: tsserver + eslint.\"\"\"\n"
                "def servers():\n"
                "    return [\n"
                "        {\"name\": \"tsserver\", \"command\": [\"typescript-language-server\", \"--stdio\"]},\n"
                "        {\"name\": \"eslint\", \"command\": [\"vscode-eslint-language-server\", \"--stdio\"]},\n"
                "    ]\n")))))

(+eglot-ensure-rass-presets)

(after! eglot
  (when (executable-find "rass")
    (add-to-list 'eglot-server-programs '(python-mode . ("rass" "python")))
    (add-to-list 'eglot-server-programs '(python-ts-mode . ("rass" "python")))
    (add-to-list 'eglot-server-programs '(js-mode . ("rass" "javascript")))
    (add-to-list 'eglot-server-programs '(js-ts-mode . ("rass" "javascript")))
    (add-to-list 'eglot-server-programs '(typescript-mode . ("rass" "javascript")))
    (add-to-list 'eglot-server-programs '(typescript-ts-mode . ("rass" "javascript")))))
