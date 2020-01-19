;;; cnsunyour/telega/config.el -*- lexical-binding: t; -*-


;; telegram client for emacs
(use-package! telega
  :commands (telega)
  :defer t
  :bind ("C-M-S-s-t" . #'telega)
  :init
  (unless (display-graphic-p) (setq telega-use-images nil))
  :hook
  ('telega-chat-mode . #'yas-minor-mode-on)
  ('telega-chat-mode . (lambda ()
                         (set-company-backend! 'telega-chat-mode
                           (append '(telega-company-emoji
                                     telega-company-username
                                     telega-company-hashtag)
                                   (when (telega-chat-bot-p telega-chatbuf--chat)
                                     '(telega-company-botcmd))))))
  ('telega-chat-pre-message . #'telega-msg-ignore-blocked-sender)
  :config
  (defadvice! +toggle-input-method--telega-chat-mode-a (chat)
    "在 telega-chat-mode 里根据 chat 名称切换输入法，如果名称包含
中文，则激活中文输入法，否则关闭中文输入法"
    :after #'telega-chat--pop-to-buffer
    (let ((title (telega-chat-title chat))
          (cn-list (list "#archlinux-cn"
                         "wikipedia-zh"
                         "Jetbrains Agent"
                         "SCP-079-CHAT"))
          (en-list (list "telega.el")))
      (cond ((member title cn-list) (activate-input-method "pyim"))
            ((member title en-list) (activate-input-method nil))
            ((string-match "\\cc" title) (activate-input-method "pyim"))
            ((telega-chat-bot-p chat) (activate-input-method nil))
            ((telega-chat-private-p chat) (activate-input-method "pyim"))
            (t (activate-input-method nil)))))

  (set-evil-initial-state! '(telega-root-mode telega-chat-mode) 'emacs)

  (setq telega-proxies (list '(:server "127.0.0.1" :port 1086 :enable t
                                       :type (:@type "proxyTypeSocks5")))
        telega-chat-reply-prompt "<<< "
        telega-chat-edit-prompt "+++ "
        telega-chat-use-markdown-version nil
        telega-animation-play-inline t
        telega-emoji-use-images nil
        telega-sticker-set-download t)
  (pushnew! telega-known-inline-bots
             "@vid" "@bing" "@wiki" "@imdb")

  (set-popup-rule! (regexp-quote telega-root-buffer-name)
    :side 'right :size 100 :quit t :modeline t)
  (set-popup-rule! "^◀[[({<].*[\])}>]$"
    :side 'right :size 100 :quit t :modeline t)

  (telega-mode-line-mode 1)
  (telega-url-shorten-mode 1)

  (when (featurep! :completion ivy)
    (load! "+ivy-telega"))

  (after! all-the-icons
    (add-to-list 'all-the-icons-mode-icon-alist
                 '(telega-root-mode all-the-icons-fileicon "telegram"
                                    :heigt 1.0
                                    :v-adjust -0.2
                                    :face all-the-icons-yellow))
    (add-to-list 'all-the-icons-mode-icon-alist
                 '(telega-chat-mode all-the-icons-fileicon "telegram"
                                    :heigt 1.0
                                    :v-adjust -0.2
                                    :face all-the-icons-blue))))
