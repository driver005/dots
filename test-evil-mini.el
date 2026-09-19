(setq evil-collection-setup-minibuffer t)
(after! vertico
  (map! :map vertico-map
        :i "<escape>" #'evil-normal-state
        :n "<escape>" #'abort-recursive-edit
        :n "E" #'+vertico/embark-export-write
        :n "j" #'vertico-next
        :n "k" #'vertico-previous))
