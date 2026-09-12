;;; plugin/dev/lang/packages.el -*- lexical-binding: t; no-byte-compile: t -*-

;; bazel: no dedicated Doom :lang module exists for Bazel. Official package
;; (bazelbuild/emacs-bazel-mode). Handles BUILD/BUILD.bazel/WORKSPACE/
;; WORKSPACE.bazel and *.bzl files (bazel-mode / bazel-starlark-mode) with
;; its own auto-mode-alist entries out of the box.
(package! bazel)
