;;; plugin/dev/tools/packages.el -*- lexical-binding: t; no-byte-compile: t -*-

(package! magit-todos)

;; magit-gptcommit uses the generic `llm' library (many providers, not
;; hardcoded OpenAI despite the name) - configured against Gemini in
;; config.el, reusing the existing GEMINI_API_KEY, no new signup needed.
(package! magit-gptcommit)
(package! llm)
