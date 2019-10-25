;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here
(setq user-full-name "Sunn Yao"
      frame-title-format (concat "%b - " user-full-name "'s Emacs")
      user-mail-address "sunyour@gmail.com"
      epa-file-encrypt-to user-mail-address)

;; Set doom font family and size
(setq doom-font (font-spec :family "Iosevka" :size 16))

;; System locale to use for formatting time values.
(setq system-time-locale "C")         ; Make sure that the weekdays in the
                                      ; time stamps of your Org mode files and
                                      ; in the agenda appear in English.

;; 设置我所在地方的经纬度，calendar里有个功能是日月食的预测，和经纬度相联系的。
;; 让emacs能计算日出日落的时间，在 calendar 上用 S 即可看到
;; 另外根据日出日落时间切换主题也需要经纬度
(setq calendar-location-name "Beijing, China")
(setq calendar-latitude +39.9055472)
(setq calendar-longitude +116.3887056)

;; 让flycheck检查载入el文件时从load-path里搜索
(setq flycheck-emacs-lisp-load-path 'inherit)

(use-package! exec-path-from-shell
  :when IS-MAC
  :config
  (setq exec-path-from-shell-arguments '("-l"))
  (exec-path-from-shell-initialize))

;; 启用epa-file，可以解密.authinfo.gpg文件
;; (use-package! epa-file :config (epa-file-enable))
;; 启用auth-source-pass，可以使用.password-store里的密码
;; (use-package! auth-source-pass :config (auth-source-pass-enable))
;; 启用auto-soure，读取.autoinfo或.authinfo.gpg里的难信息
;; (use-package! auth-source)

(load! "+bindings")
(load! "+chinese")
(load! "+calendar")
(load! "+org")
(load! "+myblog")
(load! "+translate")
(load! "+manateelazycat")

(use-package! fuz
  :config
  (unless (require 'fuz-core nil t)
    (fuz-build-and-load-dymod)))

(use-package! pinentry
  :config
  (pinentry-start))

;; 设置latex编辑tex文件时用skim同步显示pdf
(setq TeX-source-correlate-mode t)
(setq TeX-source-correlate-start-server t)
(setq TeX-source-correlate-method 'synctex)
(setq TeX-view-program-list
      '(("Skim" "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g %n %o %b")))
(setq TeX-view-program-selection '((output-pdf "Skim")))

;; Symbol Overlay 多关键字高亮插件
;; Highlight symbols with overlays while providing a keymap for various
;; operations about highlighted symbols. It was originally inspired by
;; the package highlight-symbol. The fundamental difference is that in
;; symbol-overlay every symbol is highlighted by the Emacs built-in
;; function overlay-put rather than the font-lock mechanism used in
;; highlight-symbol.
;; Default key-bindings defined in symbol-overlay-map:
;; "i" -> symbol-overlay-put
;; "n" -> symbol-overlay-jump-next
;; "p" -> symbol-overlay-jump-prev
;; "w" -> symbol-overlay-save-symbol
;; "t" -> symbol-overlay-toggle-in-scope
;; "e" -> symbol-overlay-echo-mark
;; "d" -> symbol-overlay-jump-to-definition
;; "s" -> symbol-overlay-isearch-literally
;; "q" -> symbol-overlay-query-replace
;; "r" -> symbol-overlay-rename
(map! :g "M-i" 'symbol-overlay-put
      :g "M-n" 'symbol-overlay-switch-forward
      :g "M-p" 'symbol-overlay-switch-backward
      :g "<f7>" 'symbol-overlay-mode
      :g "<f8>" 'symbol-overlay-remove-all)

;; tabnine，一个非常牛的补全插件
(use-package! company-tabnine
  :when (featurep! :completion company)
  :config
  ;; (add-to-list 'company-backends #'company-tabnine)
  (set-company-backend! 'prog-mode
    'company-tabnine 'company-capf 'company-yasnippet)
  (setq +lsp-company-backend '(company-lsp :with company-tabnine :separate)))
  ;; (setq +lsp-company-backend '(company-tabnine :with company-lsp :separate))
  ;; Trigger completion immediately.
  ;; (setq company-idle-delay 0)
  ;; Number the candidates (use M-1, M-2 etc to select completions).
  ;; (setq company-show-numbers t)
  ;; Use the tab-and-go frontend.
  ;; Allows TAB to select and complete at the same time.
  ;; (company-tng-configure-default)
  ;; (setq company-frontends
  ;;       '(company-tng-frontend
  ;;         company-pseudo-tooltip-frontend
  ;;         company-echo-metadata-frontend)))

;; plantuml-mode & ob-plantuml
(after! plantuml-mode
  ;; Change plantuml exec mode to `executable', other mode failed.
  (setq plantuml-default-exec-mode 'executable)
  ;; 设定plantuml的jar文件路径
  (setq plantuml-jar-path
        (cond
         (IS-MAC
          "/usr/local/opt/plantuml/libexec/plantuml.jar")
         (IS-LINUX
          "/usr/share/java/plantuml/plantuml.jar"))
        org-plantuml-jar-path plantuml-jar-path))

;; beancount复式账簿记账
(use-package! beancount
  :load-path "~/hg/beancount/editors/emacs"
  :ensure nil
  :defer t
  :mode
  ("\\.bean\\(?:count\\)?\\'" . beancount-mode)
  :config
  (add-hook 'beancount-mode-hook #'yas-minor-mode-on t))

(use-package! docker
  :defer t
  :bind ("C-c d" . docker)
  :custom (docker-image-run-arguments '("-i" "-t" "--rm")))

(use-package! weechat :defer t)

;; (use-package! ansible
;;   :after yaml-mode
;;   :config
;;   (add-hook 'ansible-hook 'ansible-auto-decrypt-encrypt)
;;   (add-hook 'yaml-mode-hook '(lambda () (ansible 1)))
;;   (add-to-list 'company-backends 'company-ansible))

(use-package! telega
  :when (display-graphic-p)
  :commands (telega)
  :defer t
  :bind ("C-c t" . #'telega)
  :config
  (setq telega-proxies
      (list
       '(:server "127.0.0.1" :port 1086 :enable t
                 :type (:@type "proxyTypeSocks5"))))
  (add-hook! '(telega-root-mode-hook telega-chat-mode-hook) #'evil-emacs-state)
  (add-hook 'telega-chat-pre-message-hook #'telega-msg-ignore-blocked-sender)
  (set-popup-rule! "^\\*Telega Root" :side 'right :size 100 :quit t)
  (set-popup-rule! "^◀\\[.*\\]" :side 'right :size 100 :quit t :modeline t)
  (telega-mode-line-mode 1)
  (telega-notifications-mode 1))

;; define environmental variable for some works
(setenv "PKG_CONFIG_PATH"
        (concat
         "/usr/local/opt/libffi/lib/pkgconfig" path-separator
         "/usr/local/opt/qt/lib/pkgconfig" path-separator
         "/usr/local/opt/nss/lib/pkgconfig" path-separator
         (getenv "PKG_CONFIG_PATH")))

;; 设定popup的窗口形式为右侧开启，宽度为40%
;; (set-popup-rule! "^\\*" :side 'right :size 0.5 :select t)

;; 80列太窄，120列太宽，看着都不舒服，100列正合适
;; (setq-default fill-column 100)

;; 虚拟换行设置
;; (setq-default visual-fill-column-width 120)
;; (global-visual-fill-column-mode 1)
;; (global-visual-line-mode 1)

;; To fix the issue: Unable to load color "brightblack"
(after! hl-fill-column
  (set-face-background 'hl-fill-column-face "#555555"))

(after! doom-modeline
  (setq doom-modeline-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode-color-icon t
        doom-modeline-buffer-state-icon t
        doom-modeline-buffer-modification-icon t
        doom-modeline-enable-word-count t
        doom-modeline-indent-info t))

(after! lsp-ui
  (setq lsp-ui-doc-position 'at-point
        lsp-ui-flycheck-enable t
        lsp-ui-sideline-ignore-duplicate t
        lsp-ui-sideline-update-mode 'point
        lsp-enable-file-watchers nil
        lsp-ui-doc-enable t)
  (if (featurep 'xwidget-internal)
      (setq lsp-ui-doc-use-webkit t)))

(when IS-MAC
  (setq mac-system-move-file-to-trash-use-finder t
        delete-by-moving-to-trash t))

;; 使用相对行号
(setq display-line-numbers-type 'relative)

;; Enabling Font Ligatures in emacs-mac-port
(when (eq window-system 'mac)
  (mac-auto-operator-composition-mode))

;; 调整Mac下窗口和全屏显示方式
(when (eq window-system 'ns)
  (setq ns-use-thin-smoothing t)
  (setq ns-use-native-fullscreen nil)
  (setq ns-use-fullscreen-animation nil))

;; 调整启动时窗口大小/最大化/全屏
;; (pushnew! initial-frame-alist '(width . 200) '(height . 50))
(add-hook! 'window-setup-hook
           :append
           #'toggle-frame-maximized
           #'toggle-frame-fullscreen)

;; 每天根据日出日落时间换主题
(use-package! theme-changer
  :config
  (change-theme '(doom-one-light
                  doom-nord-light
                  doom-opera-light
                  doom-tomorrow-day
                  doom-solarized-light)
                '(doom-one
                  doom-vibrant
                  doom-dracula
                  doom-molokai
                  doom-city-lights
                  doom-challenger-deep
                  doom-Iosvkem)))

;; elisp eval
(defun eval-this-buffer ()
  (interactive)
  (eval-buffer nil (get-buffer-create "output"))
  (switch-to-buffer-other-window "output"))

;; 显示儿子的成长时间
(map! :leader :desc "Twinkle's live time." :g "k"
      (defun twinkle-live-time ()
        "Display the live time of my son."
        (interactive)
        (let* ((birth-time (encode-time 0 43 13 16 9 2013))
               (live-time  (time-subtract (current-time) birth-time))
               (lt-secs    (float-time live-time)))
          (message
           (format "Twinkle: %d days; %.2f months; %.2f weeks; -- %s"
                   (floor (/ lt-secs 86400))
                   (/ lt-secs 2628000) ;; 1 y = 12 m, 1 m ~= 30.4166667 d
                   (/ lt-secs 604800)
                   (format-seconds "%Y, %D, %H, %M%z" lt-secs))))))
