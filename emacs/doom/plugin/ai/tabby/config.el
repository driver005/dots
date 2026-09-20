;;; plugin/ai/tabby/config.el -*- lexical-binding: t; -*-

;; Talks to the Tabby server started by tabbyml.service (packaged systemd
;; --user unit, see tabby/tabby-install.sh) directly - this is what's fast
;; and live-updates the ghost text as you type. The `tabby-agent' npm CLI
;; registered as a generic lsp-mode client (tried first, see git history)
;; is a much slower, indirect route: it wraps the same server behind a full
;; LSP textDocument/completion round trip with its own multi-step internal
;; pipeline (collect snippets -> fetch -> cache), consistently slower than
;; typing cadence - `cape-dabbrev' (local, no network) was the only capf
;; that ever finished in time through that path. Dropped entirely in favor
;; of this, tabby.el's own native connection, for the same responsiveness
;; the ghost text always had.
(use-package! tabby
  :hook (prog-mode . tabby-mode)
  :init
  (setq tabby-enable-predicates '(evil-insert-state-p)
        ;; `tabby--post-command' dismisses the current suggestion and
        ;; schedules a fresh one on ANY command that isn't tabby-prefixed,
        ;; self-insert, or in this list. corfu's own navigation/interaction
        ;; commands don't match any of those, so moving the selection onto
        ;; tabby's own candidate in the dropdown (`corfu-next' etc) looked
        ;; to tabby.el like "the user did something else" - dismiss,
        ;; regenerate - which is what showed up as the list refreshing and
        ;; tabby's candidate jumping to the end (a genuinely new suggestion
        ;; landing via the normal merge, not the deliberately-sorted one).
        tabby-clear-overlay-ignore-commands
        '(corfu-next corfu-previous corfu-first corfu-last
          corfu-scroll-up corfu-scroll-down
          corfu-insert corfu-complete corfu-expand
          corfu-insert-separator corfu-reset))
  :config
  (map! :map tabby-mode-map
        :i "C-j" #'tabby-accept-completion
        :i "C-<tab>" #'tabby-accept-completion-by-word
        :i "C-l" #'tabby-accept-completion-by-line))

;; The `tabby-clear-overlay-ignore-commands' setting above (checked against
;; `this-command' only, matching tabby.el's own upstream `tabby--post-command')
;; didn't actually stop corfu-navigation from dismissing the suggestion -
;; confirmed by pulling copilot.el's source (a much more battle-tested
;; ghost-text package solving the exact same "don't dismiss on some
;; commands" problem) and finding it checks BOTH `this-command' AND
;; `this-original-command':
;;
;;   (member this-command copilot-clear-overlay-ignore-commands)
;;   (member this-original-command copilot-clear-overlay-ignore-commands)
;;
;; `this-original-command' is what Emacs records BEFORE any `[remap ...]'
;; substitution resolves the actual command to run - if anything in this
;; stack (evil, corfu's own keymap handling) causes `this-command' to differ
;; from what was literally invoked, checking only `this-command' misses it,
;; which is exactly the gap here. tabby.el's own upstream `tabby--post-command'
;; has no such check, and it's a third-party straight package (not one of
;; our own files) - not something to hand-edit in place, so this replaces
;; it outright with a corrected version doing the same two-way check.
(defun +tabby-post-command ()
  "Complete in `post-command-hook' hook. Copied from tabby.el's own
`tabby--post-command' and extended with `this-original-command' checking,
adapted from copilot.el's `copilot--post-command' (same problem, same fix)."
  (when (and this-command
             (not (and (symbolp this-command)
                       (or
                        (s-starts-with-p "tabby-" (symbol-name this-command))
                        (member this-command tabby-clear-overlay-ignore-commands)
                        (member this-original-command tabby-clear-overlay-ignore-commands)
                        (tabby--self-insert this-command)))))
    (tabby-dismiss)
    (when tabby--post-command-timer
      (cancel-timer tabby--post-command-timer))
    (setq tabby--post-command-timer
          (run-with-idle-timer tabby-idle-delay
                               nil
                               'tabby--post-command-debounce
                               (current-buffer)))))

(advice-add #'tabby--post-command :override #'+tabby-post-command)

;; Bridges tabby's ghost-text suggestion into the normal capf pipeline, so
;; it shows as a candidate in corfu's dropdown too, not just as an inline
;; overlay. `tabby-current-completion' is tabby's own public accessor
;; (not a private internal) for whatever it's currently suggesting - real
;; integration point, not a hack. Only returns a spec when a suggestion
;; exists, so it's a no-op (falls through to LSP/dabbrev) otherwise.
;;
;; Two shapes, depending on what's under point:
;;
;; - Mid-identifier (there's a partial symbol right before point, e.g. you
;;   just typed "wri" of "write_file"): report `beg' at the START of that
;;   symbol, same as LSP/dabbrev would, and prepend the already-typed part
;;   to tabby's own suggestion so the candidate is the full completed
;;   symbol. This is what lets `+tabby-merged-capf' below actually merge
;;   tabby in alongside LSP instead of hiding it - `cape-wrap-super' only
;;   merges tables that share the same `beg' as the first (real) result;
;;   anything with a different `beg' gets silently dropped from the merge
;;   (confirmed in cape.el's `cape--super-prefix').
;; - Plain insertion (point is after whitespace/punctuation, no partial
;;   symbol - e.g. tabby suggesting a whole "+ b" after "return a "): no
;;   sensible shared `beg' exists (LSP has nothing to offer at this
;;   position anyway), so fall back to a zero-width spec. This one still
;;   wins exclusively while active, but that only matters for positions
;;   where LSP wouldn't be showing anything regardless.
;;
;; `:company-prefix-length t' on the zero-width branch is load-bearing, not
;; decorative: Doom's stock corfu module sets `corfu-auto-prefix' to 2, and
;; `corfu--capf-wrapper' rejects any capf whose match length is below that
;; - measured as `(- (point) beg)' when the capf doesn't say otherwise.
;; Since beg = end = (point) there, that length is always 0 and corfu-auto
;; silently drops it on every real keystroke otherwise - confirmed by
;; reading corfu-auto.el/corfu.el source. `t' tells corfu to skip the
;; length check entirely, the same escape hatch company/capf ghost-text
;; backends (e.g. copilot.el) use. Not needed on the mid-identifier branch
;; since `beg' is genuinely earlier than point there.
(defun +tabby-capf--raw ()
  (when-let* ((suggestion (tabby-current-completion))
              ((not (string-empty-p suggestion))))
    (let ((sym-start (save-excursion (skip-syntax-backward "w_") (point))))
      (if (= sym-start (point))
          (list (point) (point)
                (list suggestion)
                :exclusive 'no
                :company-prefix-length t
                :company-kind (lambda (_) 'text))
        (list sym-start (point)
              (list (concat (buffer-substring-no-properties sym-start (point))
                            suggestion))
              :exclusive 'no
              :company-kind (lambda (_) 'text))))))

;; Accepting tabby's candidate via `tabby-accept-completion' itself (`C-j'
;; etc.) does more than just insert text: it posts a "select" telemetry
;; event to the tabby server, deletes any trailing text the suggestion was
;; meant to REPLACE (`suffix-replace-chars' - relevant when tabby's
;; suggestion overlaps existing text ahead of point, not just inserts),
;; and clears tabby's own overlay/state. Accepting the SAME candidate from
;; corfu's popup (RET/TAB - `corfu-insert'/`corfu-complete') goes through
;; plain completion-at-point insertion instead, which does none of that -
;; it would silently skip the telemetry, leave stale trailing text
;; uncleaned, and leave a dangling overlay reference. `:exit-function' is
;; the standard, protocol-level capf hook for exactly this ("do cleanup
;; after MY candidate gets inserted, however it got inserted") -
;; `cape-wrap-properties' is cape's own utility for attaching one. Using
;; it specifically (rather than hand-editing the plist) matters because
;; `+tabby-merged-capf' merges this capf with others via `cape-wrap-super',
;; and cape's OWN per-candidate `:exit-function' dispatch (tagging each
;; merged candidate with which sub-capf produced it) is what correctly
;; routes this to fire ONLY for tabby's own candidate, never for a
;; clangd/dabbrev one sitting right next to it in the same popup.
(defun +tabby-capf-exit (_string _status)
  "Replicate `tabby-accept-completion''s side effects (telemetry, trailing
-text cleanup, overlay clearing) after tabby's candidate is inserted via
completion-at-point machinery instead of `tabby-accept-completion' itself."
  (when (overlayp tabby--overlay)
    (let ((suffix-replace-chars (overlay-get tabby--overlay 'suffix-replace-chars))
          (completion-id (overlay-get tabby--overlay 'completion-id))
          (choice-index (overlay-get tabby--overlay 'choice-index)))
      (when completion-id
        (tabby--agent-post-event
         `(:type "select" :completion_id ,completion-id :choice_index ,choice-index)))
      (when (and suffix-replace-chars (> suffix-replace-chars 0))
        (delete-region (point) (+ (point) suffix-replace-chars)))
      (tabby--clear-overlay))))

(defun +tabby-capf ()
  (cape-wrap-properties #'+tabby-capf--raw :exit-function #'+tabby-capf-exit))

;; `completion-at-point-functions' is a first-success chain, not a merge -
;; whichever capf answers first wins the WHOLE corfu popup, the rest never
;; run. Wrapping tabby together with everything else via `cape-wrap-super'
;; (listing tabby first, so its candidate sorts first - `cape-wrap-super'
;; preserves argument order, no re-sorting) is what actually gets both
;; shown at once, for the mid-identifier case above where their `beg's
;; agree. Note: `cape-wrap-super', not `cape-capf-super' - the latter only
;; BUILDS a capf closure for storing in the hook variable, it doesn't run
;; anything; `cape-wrap-super' runs the given capfs and returns the merged
;; spec immediately, which is what a capf being called right now needs.
;; `remq' drops this very function from the list it's about to wrap, so it
;; doesn't try to nest itself. `add-hook' appends the literal symbol `t' to
;; a buffer-local hook value (meaning "also run the global value here") -
;; `cape-wrap-super' isn't expecting that and tries to funcall it directly,
;; throwing `(void-function t)' and silently killing the whole capf -
;; confirmed live, `seq-filter #'functionp' drops `t' (and any other
;; non-function noise) before it ever reaches `cape-wrap-super'.
;;
;; `cape-wrap-super' sets `:display-sort-function'/`:cycle-sort-function'
;; to `identity' on its own (meant to mean "preserve the argument order I
;; was given, tabby first"), and the underlying merged TABLE genuinely
;; returns tabby's candidate first when queried directly - confirmed live
;; via `all-completions' on the raw returned table. But that `identity'
;; has to survive `completion-extra-properties' -> corfu's own
;; `corfu--metadata-get' -> `corfu--sort-function' before it actually
;; controls what's drawn, several layers this session repeatedly found
;; genuine bugs in - so rather than trust it, override both sort
;; properties here with an explicit function that always floats tabby's
;; own candidate string(s) to the front, verifiable independent of
;; whatever corfu's metadata plumbing actually does with `identity'.
(defun +tabby--merge-with (others)
  "Merge tabby's own suggestion with the capfs in OTHERS (a list of
zero-arg functions), tabby's candidate(s) always floated to the front.
Shared by `+tabby-merged-capf' (the normal hook-based path) and
`+tabby-merge-into-lsp-capf' below (a direct-advice path needed because
lsp-mode doesn't respect hook depth - see its comment)."
  (let* ((tabby-spec (+tabby-capf))
         (tabby-cands (and tabby-spec (nth 2 tabby-spec)))
         (res (apply #'cape-wrap-super #'+tabby-capf others)))
    (when (and (consp res) tabby-cands)
      (let ((float-tabby-first
             (lambda (cands)
               (append (seq-filter (lambda (c) (member c tabby-cands)) cands)
                       (seq-remove (lambda (c) (member c tabby-cands)) cands)))))
        (setcdr (nthcdr 2 res)
                (thread-first (nthcdr 3 res)
                              (plist-put :display-sort-function float-tabby-first)
                              (plist-put :cycle-sort-function float-tabby-first)))))
    res))

(defun +tabby-merged-capf ()
  (+tabby--merge-with
   (seq-filter #'functionp (remq #'+tabby-merged-capf completion-at-point-functions))))

;; Registered at depth -90, meant to run ahead of every other capf Doom's
;; corfu module wires up (cape-file at -10, LSP at 0, cape-dabbrev at 20).
;; In practice this alone isn't reliable: lsp-mode registers its own capf
;; via `(add-to-list 'completion-at-point-functions #'lsp-completion-at-point)'
;; (see lsp-completion.el) - `add-to-list', not `add-hook', so it ignores
;; depth entirely and just shoves itself onto the FRONT of the list
;; whenever lsp-mode (re)activates for the buffer, regardless of when this
;; hook ran. Confirmed live: after an LSP reconnect,
;; `completion-at-point-functions' had `lsp-completion-at-point' ahead of
;; `+tabby-merged-capf' despite the -90 depth here, so tabby's own capf
;; never even ran - clangd's result won the whole chain outright, which is
;; why the suggestion kept showing up last (leaking in some other way,
;; e.g. corfu's own preview) instead of merged and floated to the top.
;; This registration is kept as the correct behavior for buffers with NO
;; language server (plain prog-mode, no LSP) - the direct advice below is
;; what actually makes the merge reliable when LSP is involved.
(add-hook! 'tabby-mode-hook
  (add-hook 'completion-at-point-functions #'+tabby-merged-capf -90 t))

;; Bypasses the hook-ordering unreliability above entirely: whenever
;; `lsp-completion-at-point' itself gets called - no matter where it sits
;; in the list, or whether it's the only entry that ever gets tried -
;; merge tabby's own suggestion into ITS result directly, using the
;; already-computed RESULT as a literal one-item "others" list (a zero-arg
;; function that just returns it, since `cape-wrap-super' expects to call
;; each of its arguments).
(defun +tabby-merge-into-lsp-capf (result)
  (if (and (bound-and-true-p tabby-mode) (consp result) (tabby-current-completion))
      (+tabby--merge-with (list (lambda () result)))
    result))

(advice-add #'lsp-completion-at-point :filter-return #'+tabby-merge-into-lsp-capf)

;; `tabby--overlay-show-completion' is where tabby actually renders a NEW
;; suggestion once the async agent response comes back - as opposed to
;; `tabby--post-command', which only fires the *request*. Advising it to
;; also nudge corfu-auto is what makes the dropdown open/refresh the moment
;; the suggestion lands, instead of waiting for the next keystroke's own
;; idle timer (which already ran, found nothing, and won't fire again on
;; its own). `corfu-auto--complete-deferred' (no TICK arg) is corfu-auto's
;; own "scan capfs, show popup" primitive - safe to call any time, it never
;; auto-inserts a sole candidate the way `completion-at-point' can.
;;
;; `corfu-auto--complete-deferred' also refuses to run at all while a
;; completion session is already active (`(not completion-in-region-mode)'
;; is the first thing it checks) - meaning if LSP/dabbrev already popped a
;; corfu window open while you were mid-keystroke, tabby's suggestion
;; arriving a beat later would get silently swallowed. Tearing down any
;; existing session first forces a fresh capf scan.
;;
;; Doom's stock corfu setup uses `corfu-preselect' 'prompt (nothing
;; selected until you move with TAB/down), so with a lone tabby candidate,
;; RET would just pass through as a literal newline instead of accepting
;; it. Force-preselecting it here, scoped to this call via dynamic let,
;; makes RET/TAB accept immediately without touching corfu's normal
;; (LSP/dabbrev) preselect behavior elsewhere.
;; `corfu-preview-current' (on by default, 'insert) already draws the
;; preselected candidate as inline ghost text once the popup is open, and
;; tabby's own suggestion is now always the one preselected (`corfu-preselect'
;; 'first, right below) and correctly floated to the top of the popup - so
;; corfu's own popup + preview is now the SOLE visible representation.
;; Tabby's own native ghost-text overlay is fully suppressed at the source
;; (see the advice on `tabby--set-overlay-text' further down: it always
;; strips `after-string'/`display', unconditionally, not just when this
;; function happens to open a popup) - it only continues to exist as a
;; pure DATA carrier (the `completion' property), which is what
;; `tabby-current-completion' and `+tabby-capf' actually read from. No
;; fallback to tabby's own visual rendering anymore; the popup is reliable
;; enough now (see the fixes below) that one isn't needed.
;; One more wrinkle, found live: the very FIRST `corfu--compute' pass that
;; opens the popup can run before `completion-in-region--data' has settled
;; with this session's own plist (our `:display-sort-function' included),
;; so that first render uses corfu's plain default sort
;; (`corfu-sort-length-alpha') instead - tabby's suggestion, usually a
;; longer string than a single clangd keyword, sorts toward the END under
;; that. Confirmed live: `(corfu--sort-function)' checked moments later
;; correctly resolves to our own float-to-front function, and manually
;; re-applying that exact same (already-correct) function to the
;; already-displayed `corfu--candidates' correctly floats tabby's
;; candidate to the front - the function was never the problem, the FIRST
;; render just ran too early. Forcing one more `corfu--exhibit' right
;; after opening re-runs the same computation once everything has
;; genuinely settled, which is enough to fix it.
;; Tabby's own idle/debounce loop (`tabby--post-command-debounce') can
;; redeliver a suggestion repeatedly - the same text arriving again and
;; again while typing continues or pauses, not just once per genuinely
;; NEW suggestion. Since this function used to unconditionally tear down
;; and reopen the popup with `corfu-preselect' 'first every single time it
;; ran, that meant: navigate away from tabby's candidate to pick something
;; else, then the instant the SAME suggestion gets redelivered, selection
;; snaps straight back to tabby's candidate at the top - repeatedly,
;; visible as the list "reordering over and over" and the cursor jumping
;; top/bottom. Tracking the last suggestion text actually handled and
;; skipping the whole dance when it's unchanged is what stops the
;; re-trigger loop; a real change in suggestion text still forces a fresh
;; open (that part is the actual point of this function).
(defvar-local +tabby--last-shown-suggestion nil)

(defun +tabby-open-corfu-on-suggestion (&rest _)
  (when (and (bound-and-true-p tabby-mode)
             (bound-and-true-p corfu-mode)
             (evil-insert-state-p)
             (tabby-current-completion)
             (not (equal (tabby-current-completion) +tabby--last-shown-suggestion)))
    (setq +tabby--last-shown-suggestion (tabby-current-completion))
    (require 'corfu-auto nil t)
    (when (fboundp 'corfu-auto--complete-deferred)
      (when (bound-and-true-p completion-in-region-mode)
        (completion-in-region-mode -1))
      ;; `corfu-preselect' has to stay bound to 'first across BOTH the
      ;; initial open AND the forced re-exhibit below - it only wrapped
      ;; the first call before, so the second (the one whose result
      ;; actually sticks, see its own comment) fell back to Doom's global
      ;; default ('valid), which rarely preselects anything - confirmed
      ;; live, that's why the candidate could land on top without being
      ;; selected.
      (let ((corfu-preselect 'first))
        (corfu-auto--complete-deferred)
        (when (bound-and-true-p completion-in-region-mode)
          (when (fboundp 'corfu--exhibit)
            ;; `corfu--update' (called from `corfu--exhibit') skips
            ;; recomputing entirely when `corfu--input' already equals the
            ;; current (str . pt) - true here, since the buffer text at
            ;; point hasn't changed between the popup's first (too-early)
            ;; render and this forced retry. Resetting it first is what
            ;; actually makes the second call do real work instead of
            ;; being a silent no-op - confirmed live, without this the
            ;; extra `corfu--exhibit' call changed nothing.
            (setq corfu--input nil)
            (corfu--exhibit)
            ;; `corfu-preview-current' (the ghost-text-at-point preview,
            ;; on by default) only actually shows when the current index
            ;; DIFFERS from the preselect baseline - see
            ;; `corfu--preview-current-p''s `(/= corfu--index
            ;; corfu--preselect)' check. Since `corfu-preselect' 'first
            ;; sets BOTH to 0, tabby's own default-preselected candidate
            ;; never gets a preview by corfu's own logic - that's the
            ;; "on top but no ghost text" gap. Forcing the preselect
            ;; baseline away from 0 here (any value that isn't the
            ;; current index) is what actually makes corfu's own preview
            ;; mechanism kick in for it, verified live.
            (when (and (= corfu--index 0) (not (corfu--preview-current-p)))
              (setq corfu--preselect -1)
              (corfu--preview-current (nth 0 completion-in-region--data)
                                      (nth 1 completion-in-region--data)))))))))

(advice-add #'tabby--overlay-show-completion :after #'+tabby-open-corfu-on-suggestion)

;; Resets the "already handled this one" tracker above on a GENUINE
;; dismissal - so the duplicate-suppression only applies to the same
;; suggestion being redelivered back-to-back with nothing in between, not
;; to that exact text genuinely reappearing later after a real
;; dismiss/retype cycle.
;;
;; This has to advise `tabby-dismiss', NOT `tabby--clear-overlay' (tried
;; first, and it silently made the whole fix a no-op): `tabby-dismiss'
;; calls `tabby--clear-overlay' internally, but so does
;; `tabby--overlay-show-completion' itself, as ITS OWN first step, every
;; single time it shows ANY suggestion - including an identical
;; redelivery. Advising the lower-level function meant the tracker got
;; wiped to nil right before `+tabby-open-corfu-on-suggestion''s
;; duplicate-check ever ran (it's `:after' on the SAME outer function),
;; so the check always compared against nil and never actually suppressed
;; anything - confirmed live, that's why the "cursor jumping" kept
;; happening despite this fix already being in place. `tabby-dismiss' is
;; only called for an actual dismissal (interactively, via `keyboard-quit',
;; or from `tabby--post-command' on a real non-continuing command) - never
;; as an internal step of showing a new suggestion.
(defun +tabby-reset-last-shown (&rest _)
  (setq +tabby--last-shown-suggestion nil))

(advice-add #'tabby-dismiss :after #'+tabby-reset-last-shown)

;; Suppresses tabby's own native ghost-text visual entirely, always - not
;; conditional on whether corfu's popup actually ends up showing. The
;; popup (plus corfu's own preview overlay) is now the only place the
;; suggestion is ever drawn; this overlay continues to exist purely as
;; the DATA source `tabby-current-completion'/`+tabby-capf' read from
;; (its `completion' property, untouched here), it's just never rendered
;; as text in the buffer. `:after' on `tabby--set-overlay-text' (not
;; `tabby--overlay-show-completion') so this also covers any other
;; caller of that function, not just the one path advised above.
(defun +tabby-suppress-overlay-text (&rest _)
  (when (overlayp tabby--overlay)
    (overlay-put tabby--overlay 'after-string nil)
    (overlay-put tabby--overlay 'display nil)))

(advice-add #'tabby--set-overlay-text :after #'+tabby-suppress-overlay-text)

;; `tabby-accept-completion' takes an optional string->string TRANSFORM-FN
;; applied to the completion before insertion - see `plugin/ai/tabby/balancer.el'
;; (ported from copilot.el's copilot-balancer.el) for why this matters in
;; Lisp modes. Only supplies one when the caller didn't already pass one
;; explicitly (`tabby-accept-completion-by-word'/`-by-line' both call
;; `tabby-accept-completion' internally with their own transform-fn, which
;; must win here). Start/end mirror exactly what `tabby-accept-completion'
;; itself reads off the pending overlay for the same purpose.
(defun +tabby-accept-completion-a (orig-fn &optional transform-fn)
  (funcall orig-fn
           (or transform-fn
               (when (tabby--overlay-visible)
                 (let ((start (point))
                       (end (+ (point) (or (overlay-get tabby--overlay 'suffix-replace-chars) 0))))
                   (lambda (completion) (tabby-balancer-fix-completion start end completion)))))))

(advice-add #'tabby-accept-completion :around #'+tabby-accept-completion-a)

;; Registering a project for repo-index-aware completion is purely
;; server-side (a [[repositories]] entry in ~/.config/tabbyml/config.toml -
;; tabby.el itself has no concept of repos/indexing). This just automates
;; editing that file.
(defun +tabby-index-project ()
  "Register the current project with Tabby for repo-indexing.
Appends a [[repositories]] entry to ~/.config/tabbyml/config.toml (if not
already present) and restarts tabbyml.service to pick it up."
  (interactive)
  (let* ((root (directory-file-name (or (doom-project-root) default-directory)))
         (name (file-name-nondirectory root))
         (git-url (format "file://%s" root))
         (config-file (expand-file-name "tabbyml/config.toml" (xdg-config-home))))
    (if (and (file-exists-p config-file)
             (with-temp-buffer
               (insert-file-contents config-file)
               (search-forward git-url nil t)))
        (message "Tabby: %s is already registered" name)
      (unless (file-exists-p config-file)
        (user-error "Tabby: %s doesn't exist yet - run tabby/tabby-install.sh first" config-file))
      (with-temp-buffer
        (insert (format "\n[[repositories]]\nname = \"%s\"\ngit_url = \"%s\"\n" name git-url))
        (append-to-file (point-min) (point-max) config-file))
      (message "Tabby: registered %s, restarting server to index..." name)
      (start-process "tabby-restart" nil "systemctl" "--user" "restart" "tabbyml.service")
      (+tabby-show-log))))

(defun +tabby--log-filter (proc string)
  "Standard tailing filter: keep point pinned to the end as output arrives."
  (when (buffer-live-p (process-buffer proc))
    (with-current-buffer (process-buffer proc)
      (let ((moving (= (point) (process-mark proc))))
        (save-excursion
          (goto-char (process-mark proc))
          (insert string)
          (set-marker (process-mark proc) (point)))
        (when moving (goto-char (process-mark proc)))))))

(defun +tabby-show-log ()
  "Open a live-tailing buffer of tabbyml.service's journal."
  (interactive)
  (when-let ((existing (get-buffer "*tabby-log*")))
    (when-let ((proc (get-buffer-process existing))) (delete-process proc))
    (kill-buffer existing))
  (let* ((buf (get-buffer-create "*tabby-log*"))
         (proc (make-process
                :name "tabby-log" :buffer buf
                :command '("journalctl" "--user" "-u" "tabbyml.service" "-f" "-n" "30")
                :filter #'+tabby--log-filter)))
    (with-current-buffer buf (set-marker (process-mark proc) (point-min)))
    (pop-to-buffer buf)))

;; Tabby re-checks every registered repo automatically once an hour
;; (SchedulerGitJob, off git commits - not raw filesystem changes).
;; Restarting the service forces that check immediately instead of waiting.
(defun +tabby-reindex-now ()
  "Restart tabbyml.service to force an immediate reindex check."
  (interactive)
  (message "Tabby: restarting server to trigger reindex...")
  (start-process "tabby-restart" nil "systemctl" "--user" "restart" "tabbyml.service")
  (+tabby-show-log))

(defun +tabby-open-ui ()
  "Open the Tabby web UI - the Jobs page there shows real per-job progress."
  (interactive)
  (browse-url "http://localhost:8080"))

;; One binding, not a prefix-map: every action (reindex, log, web UI, index
;; project, completion toggle/trigger) lives in `tabby-menu' (menu.el)
;; instead, so there's only one key to remember.
;; (map! :leader :desc "Tabby menu" "o y" #'tabby-menu)
