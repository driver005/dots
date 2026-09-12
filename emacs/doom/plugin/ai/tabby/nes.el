;;; plugin/ai/tabby/nes.el -*- lexical-binding: t; -*-

;; Ported from copilot.el's copilot-nes.el (MIT, github.com/copilot-emacs/copilot.el)
;; as INERT SCAFFOLDING. Copilot's "Next Edit Suggestions" predicts edits
;; anywhere in the file (not just ghost text at cursor) via a
;; GitHub-Copilot-specific LSP extension method,
;; `textDocument/copilotInlineEdit' - a real backend capability, not just
;; wiring. Tabby's server has no equivalent endpoint today.
;;
;; The overlay display/clear logic, track-changes-based auto-triggering,
;; auto-dismiss-on-move, and keymap are all generic LSP-range-to-overlay
;; code with nothing Copilot-specific in them, so they're ported (mostly)
;; unchanged. Dropped as not applicable to a stub with no real server:
;; - `copilot-nes--check-server-version' (version-gates copilot-language-server,
;;   a binary the tabby integration doesn't manage)
;; - the `copilot-disable-display-predicates' hook-in (a copilot.el main-file
;;   defcustom with no tabby.el equivalent to register into)
;; - every `copilot--*' internal call used only to actually PERFORM the
;;   request/notify the server (`copilot--connection-alivep',
;;   `copilot--async-request', `copilot--notify', `copilot--log', etc.) -
;;   `tabby-nes--request' is a stub, there's no request to make or
;;   protocol event to notify about.
;;
;; Only `tabby-nes--request' differs functionally: it's a no-op, since
;; there's no server call to make. Kept ready to wire up if Tabby ever
;; grows a similar capability - not hooked into any mode-hook by default,
;; since it produces no suggestions today. Use `M-x tabby-nes-mode' to
;; inspect it.

;;; Code:

(require 'cl-lib)
(require 'track-changes)

;;
;; Customization
;;

(defcustom tabby-nes-idle-delay 0.5
  "Seconds of idle time before requesting a NES suggestion."
  :type 'number
  :group 'tabby)

(defcustom tabby-nes-auto-dismiss-move-count 3
  "Number of cursor movements before auto-dismissing a suggestion."
  :type 'integer
  :group 'tabby)

(defcustom tabby-nes-auto-dismiss-distance 40
  "Max lines between point and suggestion before auto-dismissing."
  :type 'integer
  :group 'tabby)

;;
;; Faces
;;

(defface tabby-nes-deletion-face
  '((t :inherit diff-removed :strike-through t))
  "Face for text that a NES suggestion would delete."
  :group 'tabby)

(defface tabby-nes-insertion-face
  '((t :inherit diff-added))
  "Face for text that a NES suggestion would insert."
  :group 'tabby)

;;
;; Buffer-local state
;;

(defvar-local tabby-nes--edit nil
  "The pending NES edit plist, or nil.
Contains keys :text, :range, :command, and :textDocument.")

(defvar-local tabby-nes--overlays nil
  "List of overlays used to display the current NES suggestion.")

(defvar-local tabby-nes--timer nil
  "Idle timer for requesting NES suggestions.")

(defvar-local tabby-nes--move-count 0
  "Number of cursor movements since the suggestion was shown.")

(defvar-local tabby-nes--last-point nil
  "Position of point after the previous command, for detecting actual movement.")

;;
;; Internal helpers
;;

(defun tabby-nes--edit-start-line ()
  "Return the buffer line number where the current edit starts, or nil."
  (when tabby-nes--edit
    (let* ((range (plist-get tabby-nes--edit :range))
           (start (plist-get range :start)))
      (plist-get start :line))))

(defun tabby-nes--range-to-region (range)
  "Convert a (:start (:line .. :character ..) :end ..) RANGE to a
\(BEG . END) cons in buffer positions.
Copilot's own version goes through `copilot--goto-utf16-offset', since
real LSP positions are UTF-16 code units (surrogate pairs need special
handling). Since `tabby-nes--request' is a stub and nothing ever
populates a real :character offset here, this uses plain `forward-char'
instead - would need restoring proper UTF-16 offset handling if a real
endpoint is ever wired up here."
  (let* ((start (plist-get range :start))
         (end (plist-get range :end))
         (sline (plist-get start :line))
         (schar (plist-get start :character))
         (eline (plist-get end :line))
         (echar (plist-get end :character))
         beg epos)
    (save-excursion
      (goto-char (point-min))
      (forward-line sline)
      (forward-char schar)
      (setq beg (point))
      (goto-char (point-min))
      (forward-line eline)
      (forward-char echar)
      (setq epos (point)))
    (cons beg epos)))

;;
;; Overlay display
;;

(defun tabby-nes--clear ()
  "Clear the current NES suggestion and overlays."
  (mapc #'delete-overlay tabby-nes--overlays)
  (setq tabby-nes--overlays nil)
  (setq tabby-nes--edit nil)
  (setq tabby-nes--move-count 0)
  (setq tabby-nes--last-point nil))

(defun tabby-nes--display (edit)
  "Display EDIT as overlays in the buffer."
  (tabby-nes--clear)
  (setq tabby-nes--edit edit)
  (let* ((text (plist-get edit :text))
         (range (plist-get edit :range))
         (region (tabby-nes--range-to-region range))
         (beg (car region))
         (end (cdr region))
         (has-deletion (> end beg))
         (has-insertion (and text (not (string-empty-p text)))))
    ;; Deletion overlay: highlight replaced text with strikethrough
    (when has-deletion
      (let ((ov (make-overlay beg end nil nil nil)))
        (overlay-put ov 'face 'tabby-nes-deletion-face)
        (overlay-put ov 'tabby-nes t)
        (overlay-put ov 'evaporate t)
        (overlay-put ov 'priority 100)
        (push ov tabby-nes--overlays)))
    ;; Insertion overlay: show new text. The overlay is zero-width (it only
    ;; carries an `after-string'), so it must NOT be marked `evaporate' -
    ;; Emacs deletes an empty overlay the moment that property is set,
    ;; which would make the insertion invisible.
    (when has-insertion
      (let* ((insertion-text (propertize text 'face 'tabby-nes-insertion-face))
             (ov (make-overlay end end nil nil nil)))
        (overlay-put ov 'after-string insertion-text)
        (overlay-put ov 'tabby-nes t)
        (overlay-put ov 'priority 100)
        (push ov tabby-nes--overlays))))
  ;; Record point so the post-command hook can detect actual movement
  (setq tabby-nes--last-point (point)))

;;
;; Request (stub - see file header)
;;

(defun tabby-nes--request ()
  "Request a NES-style suggestion from Tabby.
STUB: Tabby's server has no next-edit-prediction endpoint today (nothing
equivalent to Copilot's `textDocument/copilotInlineEdit') - this clears
any pending edit and returns, with no network/process activity. Kept so
the rest of the plumbing (auto-triggering, overlay display, accept/dismiss,
keymap) is ready to wire up if that changes."
  (interactive)
  (tabby-nes--clear))

;;
;; Accept
;;

(defun tabby-nes-accept ()
  "Accept the current NES suggestion.
If point is far from the edit, jump there first. On second invocation
(or when already at the edit), apply the edit."
  (interactive)
  (when tabby-nes--edit
    (let* ((region (tabby-nes--range-to-region (plist-get tabby-nes--edit :range)))
           (beg (car region))
           (end (cdr region))
           (text (plist-get tabby-nes--edit :text))
           (near-edit (<= (abs (- (line-number-at-pos) (line-number-at-pos beg))) 1)))
      (if (not near-edit)
          ;; Jump to the edit location so the user can see what they're accepting
          (goto-char beg)
        ;; Clear the overlays before touching the buffer so the suggestion's
        ;; ghost text can't linger over the applied edit until the next
        ;; command (notably under evil-mode). The edit details are already
        ;; captured above, so resetting state here is safe.
        (tabby-nes--clear)
        (delete-region beg end)
        (goto-char beg)
        (insert (or text ""))))))

;;
;; Dismiss
;;

(defun tabby-nes-dismiss ()
  "Dismiss the current NES suggestion."
  (interactive)
  (tabby-nes--clear))

;;
;; Auto-triggering
;;

(defvar-local tabby-nes--track-changes-id nil
  "Tracker id from `track-changes-register' for this buffer.")

(defun tabby-nes--on-change (id &optional _distance)
  "Handle a `track-changes' signal for tracker ID.
Any buffer edit shifts the positions a pending suggestion was drawn at,
so drop it (e.g. after accepting a `tabby-mode' completion) and schedule
a fresh request. This catches every text modification, no matter which
command produced it."
  (condition-case _err
      (progn
        ;; We don't need the change details, but must fetch to re-arm the tracker.
        (track-changes-fetch id #'ignore)
        (when tabby-nes--edit
          (tabby-nes--clear))
        (tabby-nes--schedule-request))
    (error nil)))

(defun tabby-nes--too-far-p ()
  "Return non-nil if point is too far from the current suggestion."
  (when tabby-nes--edit
    (let ((edit-line (tabby-nes--edit-start-line)))
      (and edit-line
           (> (abs (- (1- (line-number-at-pos)) edit-line))
              tabby-nes-auto-dismiss-distance)))))

(defun tabby-nes--post-command ()
  "Auto-dismiss a pending suggestion once point wanders away from it.
Text edits are handled separately via `track-changes'; this only tracks
cursor movement, which does not modify the buffer."
  (when tabby-nes--edit
    (when (and tabby-nes--last-point (/= (point) tabby-nes--last-point))
      (cl-incf tabby-nes--move-count)
      (when (or (>= tabby-nes--move-count tabby-nes-auto-dismiss-move-count)
                (tabby-nes--too-far-p))
        (tabby-nes--clear))))
  (setq tabby-nes--last-point (point)))

(defun tabby-nes--schedule-request ()
  "Schedule a NES request after idle delay."
  (tabby-nes--cancel-timer)
  (setq tabby-nes--timer
        (run-with-idle-timer tabby-nes-idle-delay nil
                             #'tabby-nes--request-in-buffer
                             (current-buffer))))

(defun tabby-nes--request-in-buffer (buffer)
  "Request a NES suggestion in BUFFER if it is still live."
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (when tabby-nes-mode
        (tabby-nes--request)))))

(defun tabby-nes--cancel-timer ()
  "Cancel the pending NES idle timer."
  (when (timerp tabby-nes--timer)
    (cancel-timer tabby-nes--timer)
    (setq tabby-nes--timer nil)))

;;
;; Minor mode
;;

(defvar tabby-nes-mode-map
  (let ((map (make-sparse-keymap))
        (accept `(menu-item "" tabby-nes-accept
                             :filter ,(lambda (cmd)
                                        (when tabby-nes--edit cmd))))
        (dismiss `(menu-item "" tabby-nes-dismiss
                              :filter ,(lambda (cmd)
                                         (when tabby-nes--edit cmd)))))
    ;; Bind both TAB (C-i) and <tab> (function key) so the binding
    ;; works regardless of whether another mode intercepts <tab>
    ;; before function-key-map translates it to TAB.
    (define-key map (kbd "TAB") accept)
    (define-key map [tab] accept)
    (define-key map (kbd "C-g") dismiss)
    map)
  "Keymap for `tabby-nes-mode'.
Bindings only activate when a NES suggestion is pending.")

(defun tabby-nes--warn-without-tabby-mode (buffer)
  "Warn if BUFFER has `tabby-nes-mode' enabled but not `tabby-mode'.
NES does not start or sync the tabby connection on its own; it relies on
`tabby-mode' for that."
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (when (and tabby-nes-mode (not (bound-and-true-p tabby-mode)))
        (message "Tabby: `tabby-nes-mode' needs `tabby-mode' enabled in this buffer")))))

;;;###autoload
(define-minor-mode tabby-nes-mode
  "Minor mode for Tabby Next Edit Suggestions.
STUB - see the file header in nes.el: Tabby's server has no
next-edit-prediction endpoint today, so this mode's own request function
is a no-op. Kept as inert scaffolding, ready to wire up if that changes.

\\{tabby-nes-mode-map}"
  :lighter " NES"
  :keymap tabby-nes-mode-map
  (if tabby-nes-mode
      (progn
        ;; Warn when `tabby-mode' is missing, deferred to idle so that
        ;; enabling both modes from the same hook (in either order) doesn't
        ;; trigger a spurious warning.
        (run-with-idle-timer 0 nil
                             #'tabby-nes--warn-without-tabby-mode
                             (current-buffer))
        (unless tabby-nes--track-changes-id
          (setq tabby-nes--track-changes-id
                (track-changes-register #'tabby-nes--on-change :nobefore t)))
        (add-hook 'post-command-hook #'tabby-nes--post-command nil t))
    (tabby-nes--cancel-timer)
    (tabby-nes--clear)
    (when tabby-nes--track-changes-id
      (track-changes-unregister tabby-nes--track-changes-id)
      (setq tabby-nes--track-changes-id nil))
    (remove-hook 'post-command-hook #'tabby-nes--post-command t)))

(provide 'tabby-nes)

;;; tabby-nes.el ends here
