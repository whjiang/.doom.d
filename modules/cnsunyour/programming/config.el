;;; cnsunyour/programming/config.el -*- lexical-binding: t; -*-

;; init ccls include path
(after! ccls
  (when IS-MAC
    (setq ccls-initialization-options
          `(:clang ,(list :extraArgs ["-isystem/Library/Developer/CommandLineTools/usr/include/c++/v1"
                                      "-isystem/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include"
                                      "-isystem/usr/local/include"]
                          :resourceDir (string-trim (shell-command-to-string "clang -print-resource-dir")))))))

(after! lsp-mode
(setq lsp-print-io t)

(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-tramp-connection (lambda () (list* "/home/guobei.jwh/bin/ccls" ccls-args)))
  :major-modes '(c-mode c++-mode cuda-mode objc-mode)
  :server-id 'ccls-remote
  :remote? t
  :notification-handlers
  (lsp-ht ("$ccls/publishSkippedRanges" #'ccls--publish-skipped-ranges)
          ("$ccls/publishSemanticHighlight" #'ccls--publish-semantic-highlight))
  :initialization-options (lambda () nil)
  :library-folders-fn nil))

(setq ccls-executable "/Users/guobei/remote/ccls_wrapper")
)

;;set ssh target
(custom-set-variables
 '(tramp-default-method "ssh")
 '(tramp-default-user "guobei.jwh")
 '(tramp-default-host "11.163.188.81#35829"))

(setq tramp-verbose 500)

;;For all programming modes
;;treat underscore(_) as part of a word to be consistent with VIM
(add-hook 'prog-mode-hook #'(lambda () (modify-syntax-entry ?_ "w")))

;;avoid next-error in compilation to split window
(setq split-width-threshold nil)


