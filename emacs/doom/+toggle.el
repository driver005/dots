;;; +toggle.el -*- lexical-binding: t; -*-

;; Smart toggle booleans / increment numbers
(defun +my/toggle-bool-or-inc (amount)
  "Toggle boolean at point, or increment number."
  (interactive "p")
  (let* ((word (thing-at-point 'word t))
         (bounds (bounds-of-thing-at-point 'word))
         (lword (and word (downcase word))))
    (if (and bounds (member lword '("true" "false" "yes" "no" "on" "off")))
        (let* ((new-word (pcase lword
                           ("true" "false") ("false" "true")
                           ("yes" "no") ("no" "yes")
                           ("on" "off") ("off" "on")))
               (final-word (cond
                            ((string= word (upcase word)) (upcase new-word))
                            ((string= word (capitalize word)) (capitalize new-word))
                            (t new-word))))
          (delete-region (car bounds) (cdr bounds))
          (insert final-word))
      (evil-numbers/inc-at-pt amount))))

;; Smart toggle booleans / decrement numbers
(defun +my/toggle-bool-or-dec (amount)
  "Toggle boolean at point, or decrement number."
  (interactive "p")
  (let* ((word (thing-at-point 'word t))
         (bounds (bounds-of-thing-at-point 'word))
         (lword (and word (downcase word))))
    (if (and bounds (member lword '("true" "false" "yes" "no" "on" "off")))
        (+my/toggle-bool-or-inc amount)
      (evil-numbers/dec-at-pt amount))))

(map! :n "g=" #'+my/toggle-bool-or-inc
      :n "g-" #'+my/toggle-bool-or-dec)

(evil-set-command-property '+my/toggle-bool-or-inc :repeat t)
(evil-set-command-property '+my/toggle-bool-or-dec :repeat t)
