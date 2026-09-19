;;; plugin/ai/agent-shell-dashboard/config.el -*- lexical-binding: t; -*-

(use-package! agent-shell-dashboard
  :after agent-shell
  :commands (agent-shell-dashboard)
  :config
  (map! :leader
        (:prefix-map ("o d" . "dashboard")
         :desc "Agent shell dashboard" "d" #'agent-shell-dashboard)))
