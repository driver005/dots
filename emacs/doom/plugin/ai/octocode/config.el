;;; plugin/ai/octocode/config.el -*- lexical-binding: t; -*-

;; octocode has no fixed project path, so it's connected dynamically for
;; whatever project you're actually in via `+octocode-connect', instead of
;; a static mcp-hub-servers entry with one hardcoded path. `octocode mcp
;; --path <root>' is spawned as a subprocess over stdio per project.
(use-package! mcp
  :after gptel
  :config
  (require 'mcp-hub))

(use-package! gptel-mcp
  :after (gptel mcp)
  :bind (:map gptel-mode-map ("C-c m" . gptel-mcp-dispatch)))

(defun +octocode-connect ()
  "Connect octocode's MCP server for the current project."
  (interactive)
  (let ((root (directory-file-name (or (doom-project-root) default-directory))))
    (mcp-connect-server
     "octocode"
     :command "octocode"
     :args (list "mcp" "--path" root)
     :initial-callback
     (lambda (connection)
       (message "octocode: connected (%s)" (jsonrpc-name connection)))
     :tools-callback
     (lambda (_connection tools)
       (message "octocode: %d tools available" (length tools))))))

(defun +octocode-disconnect ()
  "Disconnect octocode's MCP server."
  (interactive)
  (mcp-stop-server "octocode")
  (message "octocode: disconnected"))

(defun +octocode-status ()
  "Open the MCP hub buffer: connection status for octocode (and any other
configured MCP server), with per-server logs (press `l' on a row)."
  (interactive)
  (mcp-hub))

(defvar +octocode--index-process nil)

;; `octocode index' reports live progress via a carriage-return spinner
;; ("Indexing: 12/55 files (21%)"). Rather than a comint buffer (eats half
;; the screen for a single percentage counter), run it fully in the
;; background: parse the percentage out of the raw output and surface it,
;; and the completion event, as plain echo-area messages.
(defun +octocode-index ()
  "Run `octocode index' for the current project in the background.
Progress ticks and the completion event appear as messages in the echo
area / *Messages* buffer. This is the actual indexing step (building the
embeddings/GraphRAG data) - `+octocode-connect' only starts the MCP
server, it doesn't index anything."
  (interactive)
  (when (process-live-p +octocode--index-process)
    (user-error "octocode: an index run is already in progress"))
  (let* ((default-directory (directory-file-name (or (doom-project-root) default-directory)))
         (name (file-name-nondirectory default-directory))
         (last-pct nil))
    (setq +octocode--index-process
          (make-process
           :name "octocode-index"
           :command '("octocode" "index")
           :connection-type 'pipe
           :filter
           (lambda (_proc string)
             (when (string-match "Indexing: \\([0-9]+\\)/\\([0-9]+\\) files (\\([0-9]+\\)%)" string)
               (let ((pct (match-string 3 string)))
                 (unless (equal pct last-pct)
                   (setq last-pct pct)
                   (message "octocode [%s]: indexing %s/%s files (%s%%)"
                            name (match-string 1 string) (match-string 2 string) pct)))))
           :sentinel
           (lambda (_proc event)
             (if (string-prefix-p "finished" event)
                 (message "octocode [%s]: indexing complete" name)
               (message "octocode [%s]: indexing stopped (%s)" name (string-trim event))))))
    (message "octocode [%s]: indexing started..." name)))

(defun +octocode-progress ()
  "Show a point-in-time snapshot of octocode's index (files, staleness)."
  (interactive)
  (let* ((default-directory (directory-file-name (or (doom-project-root) default-directory)))
         (data (with-temp-buffer
                 (call-process "octocode" nil t nil "stats" "-f" "json")
                 (goto-char (point-min))
                 (ignore-errors (json-parse-buffer :object-type 'plist)))))
    (if data
        (message "octocode: %s files indexed, %s (HEAD %s)"
                 (plist-get data :files_indexed)
                 (if (eq (plist-get data :stale) t) "STALE - reindex needed" "up to date")
                 (let ((head (plist-get data :current_head)))
                   (if head (substring head 0 (min 7 (length head))) "?")))
      (message "octocode: no index yet - run `SPC o g i' first"))))

;; Doom never nests deeper than 3 keys after the leader anywhere in its own
;; stock bindings (confirmed empirically - e.g. `SPC g f f', `SPC o a a').
;; This sits as its own sub-group directly under `SPC o' (open), a sibling
;; of `l' (llm), `t' (tabby), `c' (agent-shell) - same depth Doom itself
;; uses. `g' for "graph" (GraphRAG) - a different key sequence than the
;; separate top-level `SPC g' (git) group despite the shared letter.
;; "Connect MCP server" dropped from this menu - now automatic via
;; `+octocode-connect-maybe' below on `gptel-mode-hook'/`agent-shell-mode-hook'.
;; `+octocode-connect' itself still exists, just no longer needs a manual
;; entry point for the common case (disconnect + reconnect is still
;; reachable via `M-x +octocode-connect' if actually needed).
(map! :leader
      (:prefix-map ("o g" . "octocode")
       :desc "Disconnect" "d" #'+octocode-disconnect
       :desc "Index project" "i" #'+octocode-index
       :desc "Progress snapshot" "p" #'+octocode-progress
       :desc "Status / MCP hub" "s" #'+octocode-status))

;; Autoload octocode + Tabby whenever an AI session actually starts
;; (gptel or agent-shell), instead of requiring `SPC o g c'/`SPC o y t'
;; by hand every time. Both guards are silent no-ops on repeat calls
;; (same project's 2nd gptel buffer, etc) and silent no-ops if the tool
;; was never installed - never blocks opening a chat buffer.
(defun +octocode-connect-maybe ()
  "Connect octocode's MCP server for this project unless already running."
  (when (and (executable-find "octocode")
             (not (mcp--server-running-p "octocode")))
    (+octocode-connect)))

(defun +tabby-index-project-maybe ()
  "Register/index this project with Tabby, if Tabby is actually set up."
  (when (file-exists-p (expand-file-name "tabbyml/config.toml" (xdg-config-home)))
    (+tabby-index-project)))

(add-hook 'gptel-mode-hook #'+octocode-connect-maybe)
(add-hook 'gptel-mode-hook #'+tabby-index-project-maybe)
(add-hook 'agent-shell-mode-hook #'+octocode-connect-maybe)
(add-hook 'agent-shell-mode-hook #'+tabby-index-project-maybe)
