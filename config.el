;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

;; 增加自定义的.el文件路径
(add-to-list 'load-path (expand-file-name "~/.doom.d/elisp"))

(toggle-frame-fullscreen)

;; 中文字体包
(cnfonts-enable)
(cnfonts-set-spacemacs-fallback-fonts)

;; 取消pangu包里默认的在中英文字符之间增加空格的设置
;; (global-pangu-spacing-mode 0)
;; (set (make-local-variable 'pangu-spacing-real-insert-separtor) nil)

;; 修改pyim默认输入法为五笔，使用posframe能使输入法tooltip显示更顺畅
;; (setq pyim-default-scheme 'wubi)
;; (setq pyim-page-tooltip 'posframe)

(def-package! fcitx
  :after evil
  :config
  (fcitx-evil-turn-on))

;; 日历及纪念日相关设置
;; 设置我所在地方的经纬度，calendar里有个功能是日月食的预测，和你的经纬度相联系的。
;; 让emacs能计算日出日落的时间，在 calendar 上用 S 即可看到
(setq calendar-latitude +39.9055472)
(setq calendar-longitude +116.3887056)
(setq calendar-location-name "北京")

(defun cnsunyour/diary-chinese-anniversary (lunar-month lunar-day &optional year mark)
  (if year
      (let* ((d-date (diary-make-date lunar-month lunar-day year))
             (a-date (calendar-absolute-from-gregorian d-date))
             (c-date (calendar-chinese-from-absolute a-date))
             (cycle (car c-date))
             (yy (cadr c-date))
             (y (+ (* 100 cycle) yy)))
        (diary-chinese-anniversary lunar-month lunar-day y mark))
    (diary-chinese-anniversary lunar-month lunar-day year mark)))

(setq calendar-holidays
      '(;;公历节日
        (holiday-fixed 1 1 "元旦")
        (holiday-fixed 3 8 "妇女节")
        (holiday-fixed 5 1 "劳动节")
        (holiday-fixed 6 1 "儿童节")
        (holiday-fixed 9 10 "教师节")
        (holiday-fixed 10 1 "国庆节")
        (holiday-fixed 10 2 "国庆节")
        (holiday-fixed 10 3 "国庆节")
        ;;农历节日
        (holiday-chinese-new-year)
        (holiday-lunar 12 30 "除夕" 0)
        (holiday-lunar 1 1 "春节" 0)
        (holiday-lunar 1 2 "春节" 0)
        (holiday-lunar 1 3 "春节" 0)
        (holiday-lunar 1 15 "元宵节" 0)
        (holiday-solar-term "清明" "清明节")
        (holiday-lunar 5 5 "端午节" 0)
        (holiday-lunar 7 7 "七夕节" 0)
        (holiday-lunar 8 15 "中秋节" 0)
        ;;其它节日
        (holiday-fixed 2 14 "情人节")
        (holiday-fixed 4 1 "愚人节")
        (holiday-fixed 12 25 "圣诞节")
        (holiday-float 5 0 2 "母亲节")
        (holiday-float 6 0 3 "父亲节")
        (holiday-float 11 4 4 "感恩节")
        ;;纪念日
        ;; (holiday-fixed 9 16 "儿子生日")
        ;; (holiday-lunar 8 12 "儿子农历生日" 0)
        ;; (holiday-fixed 1 17 "老婆生日")
        ;; (holiday-lunar 12 17 "老婆农历生日" 0)
        ;; (holiday-lunar 1 2 "爸爸生日" 0)
        ;; (holiday-fixed 2 18 "爸爸公历生日")
        ;; (holiday-lunar 9 2 "妈妈生日" 0)
        ;; (holiday-fixed 10 9 "妈妈公历生日")
        ;; (holiday-fixed 7 12 "领证纪念日")
        ;; (holiday-fixed 10 4 "结婚纪念日")
        ;; (holiday-fixed 3 19 "我的生日")
        ;; (holiday-lunar 2 19 "我的农历生日" 0)
        ))
(setq mark-holidays-in-calendar t)
(setq calendar-mark-holidays-flag t)
(setq calendar-week-start-day 1)   ;;按中国习惯，周一为每周的第一天

;; org-mode config
(with-eval-after-load 'org
  (setq org-todo-keywords
        '((sequence "TODO(t!)" "STARTED(s!)" "NEXT(n@/!)" "WAITING(w@/!)" "SOMEDAY(y@/!)"
                    "|" "DONE(d!)" "ABORT(a@/!)")))
  (setq org-todo-keyword-faces
        '(("TODO" . "orange")
          ("STARTED" . "white")
          ("NEXT" . "yellow")
          ("WAITING" . "brown")
          ("SOMEDAY" . "purple")
          ("DONE" . "green")
          ("ABORT" . "red")))
  (setq org-tag-alist
        '(("FLAGGED" . ?f)
          ("@Office" . ?o)
          ("@Home" . ?h)
          ("@Way" . ?w)
          ("@Computer" . ?c)
          ("@Errands" . ?e)
          ("@Lunchtime" . ?l)))
  (setq org-tag-persistent-alist
        '(("FLAGGED" . ?f)
          ("@Office" . ?o)
          ("@Home" . ?h)
          ("@Computer" . ?c)
          ("@Errands" . ?e)
          ("@Lunchtime" . ?l)))
  (setq org-priority-faces
        '((?A . (:foreground "red"))
          (?B . (:foreground "yellow"))
          (?C . (:foreground "green"))))

  ;; 设置为DONE或ABORT状态时，会生成CLOSED时间戳
  (setq org-log-done 'time)

  (setq org-directory "~/Dropbox/org/")
  (setq org-default-notes-file (expand-file-name "inbox.org" org-directory))
  (setq org-agenda-file-gtd (expand-file-name "inbox.org" org-directory))
  (setq org-agenda-file-note (expand-file-name "note.org" org-directory))
  (setq org-agenda-file-journal (expand-file-name "journal.org" org-directory))

  (setq org-capture-templates
        '(("t" "New Todo Task" entry (file+headline org-agenda-file-gtd "Tasks")
           "* TODO [#B] %^{Task Topic}\n:PROPERTIES:\n:Created: %U\n:END:\n\t %?"
           :prepend t :empty-lines 0 :clock-in t :clock-resume t)
          ("n" "Taking Notes" entry (file+olp+datetree org-agenda-file-note)
           "* %^{Notes Topic}\n:PROPERTIES:\n:Created: %U\n:END:\n\t %?"
           :prepend t :empty-lines 0 :clock-in t :clock-resume t)
          ("j" "Keeping Journals" entry (file+olp+datetree org-agenda-file-journal)
           "* %^{Journal Topic}\n:PROPERTIES:\n:Created: %U\n:END:\n\t %?"
           :prepend t :empty-lines 0 :clock-in t :clock-resume t)))

  (setq org-agenda-skip-scheduled-delay-if-deadline t)

  (setq org-agenda-files (list "~/Dropbox/gtd/" org-agenda-file-gtd))

  (custom-set-variables
   '(org-refile-targets
     (quote (("~/Dropbox/org/inbox.org" :level . 1)
             ("~/Dropbox/gtd/personal.org" :level . 1)
             ("~/Dropbox/gtd/family.org" :level . 1)
             ("~/Dropbox/gtd/dbuav.org" :level . 1)
             ("~/Dropbox/gtd/project.org" :level . 1)
             ))))

  (defun gtd-inbox() (interactive) (find-file org-agenda-file-gtd))
  (global-set-key (kbd "C-c t") 'gtd-inbox)
  (defun gtd-note() (interactive) (find-file org-agenda-file-note))
  (global-set-key (kbd "C-c n") 'gtd-note)
  (defun gtd-journal() (interactive) (find-file org-agenda-file-journal))
  (global-set-key (kbd "C-c j") 'gtd-journal)

  ;; Do not dim blocked tasks
  (setq org-agenda-dim-blocked-tasks nil)

  ;; Compact the block agenda view
  (setq org-agenda-compact-blocks t)

  (setq org-agenda-custom-commands
        '((" " "Simple Agenda View"
           ((agenda "")
            (tags-todo "+PRIORITY=\"A\""
                       ((org-agenda-overriding-header "High-priority unfinished tasks:")))
            (tags-todo "+REFILE-LEVEL=1"
                       ((org-agenda-overriding-header "Tasks to refile:")))
            (alltodo ""
                     ((org-agenda-skip-function '(org-agenda-skip-entry-if 'timestamp))
                      (org-agenda-overriding-header "List of un-timestamp tasks:")))
            (stuck "") ;; review stuck projects as designated by org-stuck-projects
            (tags-todo "PROJECT" ((org-agenda-overriding-header "Project tasks:")))
            (tags-todo "FLAGGED" ((org-agenda-overriding-header "Flagged tasks:")))
            (todo "STARTED" ((org-agenda-overriding-header "Started tasks:")))
            (todo "NEXT" ((org-agenda-overriding-header "Next tasks:")))
            (todo "WAITING" ((org-agenda-overriding-header "Waiting tasks:")))
            (todo "SOMEDAY" ((org-agenda-overriding-header "Someday/Maybe tasks:")))
            ))
          ("n" "Notes"
           ((tags "+NOTE-LEVEL=1-LEVEL=2-LEVEL=3"
                  ((org-agenda-files '("~/Dropbox/org/note.org"))
                   (org-agenda-overriding-header "Notes")
                   (org-tags-match-list-sublevels t)))))
          ("j" "Journals"
           ((tags "+JOURNAL-LEVEL=1-LEVEL=2-LEVEL=3"
                  ((org-agenda-files '("~/Dropbox/org/journal.org"))
                   (org-agenda-overriding-header "Journals")
                   (org-tags-match-list-sublevels t)))))
          ("p" "Priorities from A to C"
           ((tags-todo "+PRIORITY=\"A\"" ((org-agenda-overriding-header "Hi-priority tasks:")))
            (tags-todo "+PRIORITY=\"B\"" ((org-agenda-overriding-header "Mi-priority tasks:")))
            (tags-todo "+PRIORITY=\"C\"" ((org-agenda-overriding-header "Lo-priority tasks:")))
            ))
          ))

  ;; 任务依赖属性，子任务没有完成，主任务不能设置为完成
  (setq org-enforce-todo-dependencies t)

  ;; 设置^和_的格式，后面不加大括号，原样输出，加大括号，则为上标和下标，也可以在org文件中指定#+OPTIONS: ^:{}
  (setq org-export-with-sub-superscripts (quote {}))

  ;; 指定条目之间用ID的方式进行连接，ID采用UUID的形式
  ;; (setq org-id-link-to-org-use-id t
  ;;       org-id-method 'uuid)
  ;; 在条目生成和文件保存时对没有ID属性的条目生成ID
  ;; (defun cnsunyour/org-add-ids-to-headlines-in-file ()
  ;;   "Add ID properties to all headlines in the current file"
  ;;   (interactive)
  ;;   (save-excursion
  ;;     (widen)
  ;;     (goto-char (point-min))
  ;;     (org-map-entries 'org-id-get-create)))
  ;; (add-hook 'org-capture-prepare-finalize-hook 'org-id-get-create)
  ;; (add-hook 'org-mode-hook
  ;;           (lambda ()
  ;;             (add-hook 'before-save-hook 'cnsunyour/org-add-ids-to-headlines-in-file nil 'local)))

  ;; 代码块语法高亮
  (setq org-src-fontify-natively t)

  ;; 设置超过Headline的重复任务不再显示
  (setq org-agenda-skip-scheduled-if-deadline-is-shown 'repeated-after-deadline)

  ;; 设置外部归档的目的地址
  (setq org-archive-location "%s_archive::datetree/")

  ;; 归档所有已完成和已中止的条目
  (defun cnsunyour/org-archive-done-tasks ()
    (interactive)
    (org-map-entries 'org-archive-subtree "/DONE" 'agenda 'archive 'comment)
    (org-map-entries 'org-archive-subtree "/ABORT" 'agenda 'archive 'comment)
    )

  ;; Remove empty LOGBOOK drawers on clock out
  (defun cnsunyour/remove-empty-drawer-on-clock-out ()
    (interactive)
    (save-excursion
      (beginning-of-line 0)
      (org-remove-empty-drawer-at "LOGBOOK" (point))))
  (add-hook 'org-clock-out-hook 'cnsunyour/remove-empty-drawer-on-clock-out 'append)


  )


;; 使用xelatex一步生成PDF
(setq org-latex-pdf-process '("xelatex -interaction nonstopmode %f"
                              "xelatex -interaction nonstopmode %f"))
(setq org-latex-to-pdf-process '("xelatex -interaction nonstopmode %f"
                                 "xelatex -interaction nonstopmode %f"))


(with-eval-after-load 'org2blog
  ;; org2blog相关设置
  (setq org2blog/wp-default-title nil)
  (setq org2blog/wp-default-categories (list "个人" "技术" "家庭" "生活"))

  (require 'auth-source) ;; or nothing if already in the load-path
  (let (credentials)
    ;; only required if your auth file is not already in the list of auth-sources
    (add-to-list 'auth-sources "~/.netrc")
    (setq credentials (auth-source-user-and-password "myblog"))
    (setq org2blog/wp-blog-alist
          `(("myblog"
             :url "http://www.sunyour.org/blog/xmlrpc.php"
             :username ,(car credentials)
             :password ,(cadr credentials)
             :tags-as-categories nil))))

  (setq org2blog/wp-buffer-template
        "#+LATEX_HEADER: \\usepackage[UTF8]{ctex}\n# #+LATEX_HEADER: \\usepackage{CJK}\n# #+LATEX_HEADER: \\setmainfont{Hack Nerd Font}\n# #+LATEX_HEADER: \\setsansfont{Hack Nerd Font}\n# #+LATEX_HEADER: \\setmonofont{Hack Nerd Font Mono}\n# #+LATEX_HEADER: \\setCJKmainfont{Source Han Sans SC}\n# #+LATEX_HEADER: \\setCJKsansfont{Source Han Sans SC}\n# #+LATEX_HEADER: \\setCJKmonofont{WenQuanYi Micro Hei Mono}\n#+TITLE: %s\n#+AUTHOR: %s\n#+DATE: %s\n#+OPTIONS: toc:nil num:nil todo:nil pri:nil tags:nil ^:nil\n#+CATEGORY: %s\n#+TAGS: \n#+DESCRIPTION: \n\n")
  (defun org2blog/wp-format-buffer-with-author (buffer-template)
    "Default buffer formatting function."
    (format buffer-template
            ;; TITLE
            (or (plist-get (cdr org2blog/wp-blog) :default-title)
                org2blog/wp-default-title
                (read-string "请输入POST标题:"))
            ;; AUTHOR
            "不一般的凡"
            ;; DATE
            (format-time-string "[%Y-%m-%d %a %H:%M]" (current-time))
            ;; CATEGORY
            (mapconcat
             (lambda (cat) cat)
             (or (plist-get (cdr org2blog/wp-blog) :default-categories)
                 org2blog/wp-default-categories)
             ", ")
            ))
  (setq org2blog/wp-buffer-format-function 'org2blog/wp-format-buffer-with-author)
  (setq org2blog/wp-show-post-in-browser 'show)

  )


;; define pkg_config_path for install pdftools
(when (memq window-system '(mac ns))
  (setenv "PKG_CONFIG_PATH"
          (concat
           "/usr/local/opt/libffi/lib/pkgconfig" path-separator
           "/usr/local/opt/qt/lib/pkgconfig" path-separator
           "/usr/local/opt/nss/lib/pkgconfig" path-separator
           (getenv "PKG_CONFIG_PATH"))))

;; 猫神出的很好用的多标签管理插件
;; (require 'awesome-tab)
;; (awesome-tab-mode t)
;; (global-set-key (kbd "s-[") 'awesome-tab-backward-tab)
;; (global-set-key (kbd "s-]") 'awesome-tab-forward-tab)
;; (global-set-key (kbd "s-{") 'awesome-tab-select-beg-tab)
;; (global-set-key (kbd "s-}") 'awesome-tab-select-end-tab)
;; (global-set-key (kbd "s-1") 'awesome-tab-select-visible-tab)
;; (global-set-key (kbd "s-2") 'awesome-tab-select-visible-tab)
;; (global-set-key (kbd "s-3") 'awesome-tab-select-visible-tab)
;; (global-set-key (kbd "s-4") 'awesome-tab-select-visible-tab)
;; (global-set-key (kbd "s-5") 'awesome-tab-select-visible-tab)
;; (global-set-key (kbd "s-6") 'awesome-tab-select-visible-tab)
;; (global-set-key (kbd "s-7") 'awesome-tab-select-visible-tab)
;; (global-set-key (kbd "s-8") 'awesome-tab-select-visible-tab)
;; (global-set-key (kbd "s-9") 'awesome-tab-select-visible-tab)
;; (global-set-key (kbd "s-0") 'awesome-tab-select-visible-tab)

;; 英文自动补全和翻译，激活命令toggle-company-english-helper
(require 'company-english-helper)

;; 输入insert-translated-name-insert激活命令，可以输入中文后按空格翻译成英文插入当前位置。
(require 'insert-translated-name)

;; 翻译当前单词
(require 'sdcv)
(global-set-key "\C-cd" 'sdcv-search-pointer+)
(global-set-key "\C-cD" 'sdcv-search-pointer)
;; (setq sdcv-say-word-p t)        ;; 是否读出语音
(setq sdcv-dictionary-data-dir (expand-file-name "~/.stardict/dic"))
(setq sdcv-dictionary-simple-list       ;setup dictionary list for simple search
      '("懒虫简明英汉词典"
        "懒虫简明汉英词典"
        "朗道英汉字典5.0"
        "朗道汉英字典5.0"))
(setq sdcv-dictionary-complete-list     ;setup dictionary list for complete search
      '("懒虫简明英汉词典"
        "懒虫简明汉英词典"
        "朗道英汉字典5.0"
        "朗道汉英字典5.0"
        "21世纪英汉汉英双向词典"
        "牛津英汉双解美化版"
        "英汉汉英专业词典"
        "新世纪英汉科技大词典"
        "现代汉语词典"
        "高级汉语大词典"))

;; 在Eshell中发送桌面通知
(require 'alert)
(defun eshell-command-alert (process status)
  "Send `alert' with severity based on STATUS when PROCESS finished."
  (let* ((cmd (process-command process))
         (buffer (process-buffer process))
         (msg (format "%s: %s" (mapconcat 'identity cmd " ") status)))
    (if (string-prefix-p "finished" status)
        (alert msg :buffer buffer :severity 'normal)
      (alert msg :buffer buffer :severity 'urgent))))
(add-hook 'eshell-kill-hook #'eshell-command-alert)
(alert-add-rule :status '(buried) ;only send alert when buffer not visible
                :mode 'eshell-mode
                :style 'notifications)


;; smartparens key-binding
(defmacro def-pairs (pairs)
  "Define functions for pairing. PAIRS is an alist of (NAME . STRING)
conses, where NAME is the function name that will be created and
STRING is a single-character string that marks the opening character.

  (def-pairs ((paren . \"(\")
              (bracket . \"[\"))

defines the functions WRAP-WITH-PAREN and WRAP-WITH-BRACKET,
respectively."
  `(progn
     ,@(loop for (key . val) in pairs
             collect
             `(defun ,(read (concat
                             "wrap-with-"
                             (prin1-to-string key)
                             "s"))
                  (&optional arg)
                (interactive "p")
                (sp-wrap-with-pair ,val)))))

(def-pairs ((paren . "(")
            (bracket . "[")
            (brace . "{")
            (single-quote . "'")
            (double-quote . "\"")
            (back-quote . "`")))

(bind-keys
 :map smartparens-mode-map
 ("C-M-a" . sp-beginning-of-sexp)
 ("C-M-e" . sp-end-of-sexp)

 ("C-<down>" . sp-down-sexp)
 ("C-<up>"   . sp-up-sexp)
 ("M-<down>" . sp-backward-down-sexp)
 ("M-<up>"   . sp-backward-up-sexp)

 ("C-M-f" . sp-forward-sexp)
 ("C-M-b" . sp-backward-sexp)

 ("C-M-n" . sp-next-sexp)
 ("C-M-p" . sp-previous-sexp)

 ("C-S-f" . sp-forward-symbol)
 ("C-S-b" . sp-backward-symbol)

 ("C-<right>" . sp-forward-slurp-sexp)
 ("M-<right>" . sp-forward-barf-sexp)
 ("C-<left>"  . sp-backward-slurp-sexp)
 ("M-<left>"  . sp-backward-barf-sexp)

 ("C-M-t" . sp-transpose-sexp)
 ("C-M-k" . sp-kill-sexp)
 ("C-k"   . sp-kill-hybrid-sexp)
 ("M-k"   . sp-backward-kill-sexp)
 ("C-M-w" . sp-copy-sexp)
 ("C-M-d" . delete-sexp)

 ("M-<backspace>" . backward-kill-word)
 ("C-<backspace>" . sp-backward-kill-word)
 ([remap sp-backward-kill-word] . backward-kill-word)

 ("C-x [" . sp-backward-unwrap-sexp)
 ("C-x ]" . sp-unwrap-sexp)

 ("C-x C-t" . sp-transpose-hybrid-sexp)

 ("C-c ("  . wrap-with-parens)
 ("C-c ["  . wrap-with-brackets)
 ("C-c {"  . wrap-with-braces)
 ("C-c '"  . wrap-with-single-quotes)
 ("C-c \"" . wrap-with-double-quotes)
 ("C-c _"  . wrap-with-underscores)
 ("C-c `"  . wrap-with-back-quotes))


;; web-mode下标签改名和高亮插件
(require 'instant-rename-tag)
(require 'highlight-matching-tag)
(highlight-matching-tag 1)
