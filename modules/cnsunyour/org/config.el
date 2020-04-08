;;;  -*- lexical-binding: t; -*-

;; Sets up a GTD workflow using Org-mode
;;
;; Mostly taken from Brent Hansen's setup
;; http://doc.norang.ca/org-mode.html
;; and kandread's doom-emacs config
;; https://github.com/kandread/doom-emacs-private

(use-package! counsel-org-clock
  :commands (counsel-org-clock-context
             counsel-org-clock-history))


;; 使用xelatex一步生成PDF
(setq org-latex-pdf-process '("xelatex -interaction nonstopmode %f"
                              "xelatex -interaction nonstopmode %f"))

;; 预览 org 和 markdown 文件
(use-package! grip-mode
  :defer t
  :commands (grip-mode)
  :init
  (map! (:map (markdown-mode-map org-mode-map)
          :localleader
          "v" #'grip-mode))
  :config
  ;; Use embedded webkit to previe
  (setq grip-preview-use-webkit t)
  ;; Setup xwidget window popup rule
  (set-popup-rule! "*xwidget" :side 'right :size .50 :select nil :quit t)
  ;; Setup github username and token for API auth
  (let ((credentials (auth-source-user-and-password "mygrip")))
    (setq grip-github-user (car credentials)
          grip-github-password (cadr credentials))))

;;
;; `org' pre private config
;;
;; set org files directory
(setq org-directory "~/org/")
;; set org gtd files directory
(defvar org-gtd-directory "~/org"
  "Default directory of org gtd files.")
;; set agenda files
(setq org-agenda-files
      (list org-gtd-directory
            (+org-capture-todo-file)
            (expand-file-name +org-capture-projects-file org-directory)))

;;
;; `org' private config
;;
(after! org
  ;; 使用F12 作为 agenda 的快捷键
  (global-set-key (kbd "<f12>") 'org-agenda)
  ;; define key of org-agenda
  ;；(map! :leader :desc "Org Agenda" "a" #'org-agenda)
  ;; set task states

  (setq org-todo-keywords '((sequence "TODO(t!)" "NEXT(n!)" "ASSIGNED(a!)" "START(s!)" "|" "DONE(d!)" "CANCELLED(c!)")))

  (setq org-todo-keyword-faces
        '(("TODO" :foreground "orange"       :weight bold)
          ("NEXT" :foreground "yellow"       :weight bold)
          ("ASSIGNED" :foreground "brown"        :weight bold)
          ("START" :foreground "white"        :weight bold)
          ("DONE" :foreground "dark green" :weight bold)
          ("CANCELLED" :foreground "grey"          :weight bold)))
  ;; set tags
  ;; (setq org-tag-alist
  ;;       '(("FLAGGED" . ?f)
  ;;         ("@Office" . ?o)
  ;;         ("@Home" . ?h)
  ;;         ("@Way" . ?w)
  ;;         ("@Computer" . ?c)
  ;;         ("@Errands" . ?e)
  ;;         ("@Lunchtime" . ?l)))
  ;;(setq org-tag-persistent-alist org-tag-alist)
  ;; trigger task states
  ;; (setq org-todo-state-tags-triggers
  ;;       '(("CANCELLED" ("CANCELLED" . t))
  ;;         ("ASSIGNED" ("ASSIGNED" . t))
  ;;         (done ("ASSIGNED") ("CANELLED"))
  ;;         ("TODO" ("ASSIGNED") ("CANCELLED"))
  ;;         ("NEXT" ("WAIT") ("CANCELLED"))
  ;;         ("START" ("WAIT") ("CANCELLED"))
  ;;         ("DONE" ("WAIT") ("CANCELLED"))))
  ;; exclude PROJ tag from being inherited
  (setq org-tags-exclude-from-inheritance '("PROJ"))
  ;; show inherited tags in agenda view
  (setq org-agenda-show-inherited-tags t)
  ;; set default notes file
  ;; (setq org-default-notes-file (expand-file-name "inbox.org" org-gtd-directory))
  ;; (setq +org-capture-todo-file (expand-file-name "todo.org" org-gtd-directory))
  ;; (setq +org-capture-projects-file (expand-file-name "projects.org" org-gtd-directory))
  ;; (setq +org-capture-notes-file (expand-file-name "notes.org" org-directory))
  ;; (setq +org-capture-journal-file (expand-file-name "journal.org" org-directory))
  ;; set capture templates

  (setq org-capture-templates
        (quote (("t" "Project todo" entry (file+headline "project.org" "Inbox")
                 "* TODO %^{Description}\n%?\n\n:LOGBOOK:\n:Added: %U\n:END:\n\n" :prepend t :kill-buffer t)
                ("n" "Project note" entry (file+headline "project.org" "Inbox")
                 "* NOTE %^{Description}\n%?\n\n:LOGBOOK:\n:Added: %U\n:END:\n\n" :prepend t :kill-buffer t)
                ("f" "Personal todo" entry (file+headline "personal.org" "Inbox")
                 "* TODO %^{Description}\n%?\n\n:LOGBOOK:\n:Added: %U\n:END:\n\n" :prepend t :kill-buffer t)
                ;;              ("j" "Work log" entry (file+headline "project.org" "WorkLog")
                ;;               "* NOTE -%Y-%m-%d%^{Description}\n%?\n\n:LOGBOOK:\n:Added: %U\n:END:\n\n" :prepend t :kill-buffer t)
                ;; note the use of "plain" instead of "entry"; using "entry" made this a top-level
                ;; headline regardless of how many * I put in the template string (wtf?).
                ("j" "Journal(done)" entry (file+olp+datetree "diary.org" "Work Log")
                 "* DONE %^{Description} \t%U \t:me:\nSCHEDULED: %T\n%?\n" :kill-buffer t)
                ;; "** DONE %<%H:%M> - %?\n" :kill-buffer t)
                ("d" "Journal(doing)" entry (file+olp+datetree "diary.org" "Work Log")
                 "* DOING %^{Description} \t%U \t:me:\nSCHEDULED: %T\n%?\n" :clock-in t :clock-keep t)
                ;;"** DOING %<%Y-%m-%d %H:%M> - %^{Description} \t:me:\n%?\nSCHEDULED: %T\n" :clock-in t :clock-keep t)
                ("i" "Interview" entry (file+headline "project.org" "Hiring")
                 "* TODO %^{Description}\n%?\n\n:LOGBOOK:\n:Added: %U\n:END:\n\n" :prepend t :kill-buffer t)
                ("m" "Meeting Notes" entry (file+headline "project.org" "Meeting")
                 "* %<%Y-%m-%d %H:%M> - 会议 %^{Description}\n%?\n\n:LOGBOOK:\n:Added: %U\n:END:\n\n" :prepend t :kill-buffer t))))
  ;;              ("j" "Journal entry" entry (function org-journal-find-location)
  ;;                               "* %(format-time-string org-journal-time-format) %^{Title}\n%i%?" :kill-buffer t)

  ;;add 'x' key in org-agenda to mark DONE and stop clocking
  (defun my/org-agenda-done (&optional arg)
    "Mark current TODO as done.
     This changes the line at point, all other lines in the agenda referring to
     the same tree node, and the headline of the tree node in the Org-mode file."
    (interactive "P")
    (org-agenda-todo "DONE")
    (org-clock-out-if-current))

  ;; (defun my/org-subtree-to-indirect-buffer ()
  ;;   (interactive)
  ;;   (let ((ind-buf (concat (buffer-name) "-narrowclone")))
  ;;     (if (get-buffer ind-buf)
  ;;         (kill-buffer ind-buf))
  ;;     (clone-indirect-buffer-other-window ind-buf t)
  ;;     (org-narrow-to-subtree)
  ;;     (switch-to-buffer ind-buf)))

  (defun my/org-agenda-mode-fn ()
    ;;(evil-set-initial-state 'org-agenda-mode 'emacs)
    (define-key org-agenda-mode-map "x" 'my/org-agenda-done)
    ;; (define-key org-agenda-mode-map "h" 'my/org-subtree-to-indirect-buffer)
    (hl-line-mode 1))

  ;;  (set-face-attribute 'hl-line nil :foreground nil :background "RoyalBlue4")
  (add-hook 'org-agenda-mode-hook #'my/org-agenda-mode-fn)

  ;;   (after! org-capture
  ;;     (defun org-new-task-capture-template ()
  ;;       "Returns `org-capture' template string for new task.
  ;; See `org-capture-templates' for more information."
  ;;       (let ((title (read-string "Task Name: "))) ;Prompt to enter the post title
  ;;         (mapconcat #'identity
  ;;                    `(,(concat "* TODO [#B] " title)
  ;;                      ":PROPERTIES:"
  ;;                      ":Created: %U"
  ;;                      ":END:"
  ;;                      "%?\n")          ;Place the cursor here finally
  ;;                    "\n")))
  ;;     (defun org-hugo-new-subtree-post-capture-template ()
  ;;       "Returns `org-capture' template string for new Hugo post.
  ;; See `org-capture-templates' for more information."
  ;;       (let* ((title (read-string "Post Title: ")) ;Prompt to enter the post title
  ;;              (fname (org-hugo-slug title)))
  ;;         (mapconcat #'identity
  ;;                    `(,(concat "* " title)
  ;;                      ":PROPERTIES:"
  ;;                      ":Created: %U"
  ;;                      ,(concat ":EXPORT_FILE_NAME: " fname)
  ;;                      ":EXPORT_DATE: %<%4Y-%2m-%2d>"
  ;;                      ":END:"
  ;;                      "%?\n")          ;Place the cursor here finally
  ;;                    "\n")))
  ;;     (defun remove-item-from-org-capture-templates (shortcut)
  ;;       (dolist (item org-capture-templates)
  ;;         (when (string= (car item) shortcut)
  ;;           (setq org-capture-templates (cl-remove item org-capture-templates)))))
  ;;     (remove-item-from-org-capture-templates "t")
  ;;     (remove-item-from-org-capture-templates "n")
  ;;     (remove-item-from-org-capture-templates "j")
  ;;     (pushnew! org-capture-templates
  ;;               '("t" "New Todo Task" entry (file+headline +org-capture-todo-file "Tasks")
  ;;                 ;; "* TODO [#B] %^{Todo Topic}\n:PROPERTIES:\n:Created: %U\n:END:\n"
  ;;                 (function org-new-task-capture-template)
  ;;                 :prepend t :clock-in t :clock-resume t :kill-buffer t)
  ;;               '("n" "Taking Notes" entry (file+olp+datetree +org-capture-notes-file)
  ;;                 ;; "* %^{Notes Topic}\n:PROPERTIES:\n:Created: %U\n:END:\n%?\n"
  ;;                 (function org-hugo-new-subtree-post-capture-template)
  ;;                 :prepend t :clock-in t :clock-resume t :kill-buffer t)
  ;;               '("j" "Keeping Journals" entry (file+olp+datetree +org-capture-journal-file)
  ;;                 ;; "* %^{Journal Topic}\n:PROPERTIES:\n:Created: %U\n:END:\n%?\n"
  ;;                 (function org-hugo-new-subtree-post-capture-template)
  ;;                 :prepend t :clock-in t :clock-resume t :kill-buffer t)))
  ;; set archive tag
  ;; (setq org-archive-tag "ARCHIVE")
  ;; set archive file
  ;;(setq org-archive-location "::* Archived Tasks")
  ;; refiling targets include any file contributing to the agenda - up to 2 levels deep
  (setq org-refile-targets '((nil :maxlevel . 1)
                             (org-agenda-files :level . 1)))
  ;; show refile targets simultaneously
  (setq org-outline-path-complete-in-steps nil)
  ;; use full outline paths for refile targets
  (setq org-refile-use-outline-path 'file)
  ;; allow refile to create parent tasks with confirmation
  (setq org-refile-allow-creating-parent-nodes 'confirm)
  ;; exclude done tasks from refile targets
  (setq org-refile-target-verify-function #'+org-gtd/verify-refile-target)
  ;; include agenda archive files when searching for things
  (setq org-agenda-text-search-extra-files (quote (agenda-archives)))
  ;; resume clocking when emacs is restarted
  (org-clock-persistence-insinuate)
  ;; change tasks to NEXT when clocking in
  (setq org-clock-in-switch-to-state #'+org-gtd/clock-in-to-next)
  ;; separate drawers for clocking and logs
  (setq org-drawers (quote ("LOGBOOK")))
  ;; insert state change notes and time stamps into a drawer
  (setq org-log-into-drawer t)
  ;; clock out when moving task to a done state
  (setq org-clock-out-when-done t)
  ;; save the running clock and all clock history when exiting Emacs, load it on startup
  (setq org-clock-persist t)
  ;; do not prompt to resume an active clock
  (setq org-clock-persist-query-resume nil)
  ;; enable auto clock resolution for finding open clocks
  (setq org-clock-auto-clock-resolution (quote when-no-clock-is-running))
  ;; Sometimes I change tasks I'm clocking quickly - this removes clocked tasks with 0:00 duration
  (setq org-clock-out-remove-zero-time-clocks t)
  ;; show agenda as the only window
  (setq org-agenda-window-setup 'current-window)
  ;; define stuck projects
  (setq org-stuck-projects '("+LEVEL=2/-DONE-CANCELLED" ("TODO" "NEXT" "ASSIGNED") ("@Launchtime") "\\<IGNORE\\>"))
  ;; perform actions before finalizing agenda view
  (add-hook 'org-agenda-finalize-hook
            (lambda ()
              (setq appt-message-warning-time 10        ;; warn 10 min in advance
                    appt-display-diary nil              ;; do not display diary when (appt-activate) is called
                    appt-display-mode-line t            ;; show in the modeline
                    appt-display-format 'window         ;; display notification in window
                    calendar-mark-diary-entries-flag t) ;; mark diary entries in calendar
              (org-agenda-to-appt)                      ;; copy all agenda schedule to appointments
              (appt-activate 1)))
  ;; exclude archived tasks from agenda view
  (setq org-agenda-tag-filter-preset '("-ARCHIVE"))
  ;; disable compact block agenda view
  (setq org-agenda-compact-blocks nil)
  ;; block tasks that have unfinished subtasks
  (setq org-enforce-todo-dependencies t)
  ;; dont't dim blocked tasks in agenda
  (setq org-agenda-dim-blocked-tasks nil)
  ;; inhibit startup when preparing agenda buffer
  (setq org-agenda-inhibit-startup nil)
  ;; limit number of days before showing a future deadline
  (setq org-deadline-warning-days 7)
  ;; Number of days to include in overview display.
  (setq org-agenda-span 'week)
  ;; retain ignore options in tags-todo search
  (setq org-agenda-tags-todo-honor-ignore-options t)
  ;; hide certain tags from agenda view
  (setq org-agenda-hide-tags-regexp (regexp-opt '("PROJ" "REFILE")))
  ;; remove completed deadline tasks from the agenda view
  (setq org-agenda-skip-deadline-if-done nil)
  ;; remove completed scheduled tasks from the agenda view
  (setq org-agenda-skip-scheduled-if-done nil)
  ;; remove completed items from search results
  (setq org-agenda-skip-timestamp-if-done t)
  ;; skip scheduled delay when entry also has a deadline.
  (setq org-agenda-skip-scheduled-delay-if-deadline t)
  ;; 设置超过Headline的重复任务不再显示
  (setq org-agenda-skip-scheduled-if-deadline-is-shown 'repeated-after-deadline)
  ;; include entries from the Emacs diary
  (setq org-agenda-include-diary nil)
  ;; custom diary file to org-ddirectory
  ;;(setq diary-file (expand-file-name "diary" org-directory))
  ;; 使用最后的clock-out时间作为条目关闭时间
  (setq org-use-last-clock-out-time-as-effective-time t)
  ;; 设置为DONE或CANCELLED状态时，会生成CLOSED时间戳
  (setq org-log-done 'time)
  ;; 代码块语法高亮
  (setq org-src-fontify-natively t)
  ;; 图片大小
  (setq org-image-actual-width 200)
  ;;(setq org-image-actual-width (/ (display-pixel-width) 3))

  ;; Popup rules
  ;; Make org-agenda pop up to right of screen, 45% of width
  (set-popup-rule! "^\\*Org Agenda" :side 'right :size 0.45 :select t :ttl nil)


  ;; custom agenda commands
  (setq org-agenda-custom-commands
        '(("r" "Archivable" todo "DONE|CANCELLED"
           ((org-agenda-overriding-header "Tasks to Archive:")
            (org-tags-match-list-sublevels nil)))
          ("f" "Flagged" tags-todo "+FLAGGED/!"
           ((org-agenda-overriding-header "Flagged Tasks:")
            (org-tags-match-list-sublevels t)))
          ("p" "Projects" tags-todo "+PROJ-LEVEL=1/!"
           ((org-agenda-overriding-header "Project Tasks:")
            (org-tags-match-list-sublevels 'indented)))
          ("n" "Notes" tags "-LEVEL=1-LEVEL=2-LEVEL=3"
           ((org-agenda-files (list (+org-capture-notes-file)))
            (org-agenda-overriding-header "Notes:")
            (org-tags-match-list-sublevels t)))
          ("j" "Journals" tags "-LEVEL=1-LEVEL=2-LEVEL=3"
           ((org-agenda-files (list +org-capture-journal-file))
            (org-agenda-overriding-header "Journals:")
            (org-tags-match-list-sublevels t)))
          ("v" "Awesome Agenda View"
           ((agenda "" ((org-agenda-overriding-header "Today's Schedule:")
                        (org-agenda-show-log t)
                        (org-agenda-log-mode-items '(clock state))
                        (org-agenda-span 'day)
                        (org-agenda-start-day "+0d")
                        (org-agenda-start-on-weekday nil)
                        (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo '("DONE" "CANCELLED")))
                        (org-agenda-todo-ignore-deadlines nil)))
            (tags-todo "-CANCELLED/!NEXT|START"
                       ((org-agenda-overriding-header "Next and Active Tasks:")))
            (agenda "" ((org-agenda-overriding-header "Upcoming Deadlines:")
                        (org-agenda-entry-types '(:deadline))
                        (org-agenda-span 'day)
                        (org-agenda-start-day "+0d")
                        (org-agenda-start-on-weekday nil)
                        (org-deadline-warning-days 30)
                        (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo '("DONE" "CANCELLED")))
                        (org-agenda-time-grid nil)))
            (agenda "" ((org-agenda-overriding-header "Week at a Glance:")
                        (org-agenda-span 5)
                        (org-agenda-start-day "+1d")
                        (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled))
                        (org-agenda-time-grid nil)
                        (org-agenda-prefix-format '((agenda . "  %-12:c%?-12t %s [%b] ")))))
            (tags "+REFILE-LEVEL=1"
                  ((org-agenda-overriding-header "Tasks to Refile:")
                   (org-tags-match-list-sublevels nil)))
            (org-agenda-list-stuck-projects)
            (tags-todo "-REFILE-PROJ-CANCELLED/!"
                       ((org-agenda-overriding-header "Standalone Tasks:")
                        (org-agenda-todo-ignore-scheduled t)
                        (org-agenda-todo-ignore-deadlines t)
                        (org-agenda-todo-ignore-timestamp t)
                        (org-agenda-todo-ignore-with-date t))))))))

;; set different line spacing on org-agenda view
(defun my:org-agenda-time-grid-spacing ()
  "Set different line spacing w.r.t. time duration."
  (save-excursion
    (let* ((background (alist-get 'background-mode (frame-parameters)))
           (background-dark-p (string= background "dark"))
           (colors (if background-dark-p
                       (list "#aa557f" "DarkGreen" "DarkSlateGray" "DarkSlateBlue")
                     (list "#F6B1C3" "#FFFF9D" "#BEEB9F" "#ADD5F7")))
           pos
           duration)
      (nconc colors colors)
      (goto-char (point-min))
      (while (setq pos (next-single-property-change (point) 'duration))
        (goto-char pos)
        (when (and (not (equal pos (point-at-eol)))
                   (setq duration (org-get-at-bol 'duration)))
          (let ((line-height (if (< duration 30) 1.0 (+ 0.5 (/ duration 60))))
                (ov (make-overlay (point-at-bol) (1+ (point-at-eol)))))
            (overlay-put ov 'face `(:background ,(car colors)
                                                :foreground
                                                ,(if background-dark-p "black" "white")))
            (setq colors (cdr colors))
            (overlay-put ov 'line-height line-height)
            (overlay-put ov 'line-spacing (1- line-height))))))))
(add-hook 'org-agenda-finalize-hook #'my:org-agenda-time-grid-spacing)

;; terminal-notifier
(after! org-pomodoro
  (when (executable-find "terminal-notifier")
    (defun notify-osx (title message)
      (call-process "terminal-notifier"
                    nil 0 nil
                    "-group" "Emacs"
                    "-title" title
                    "-sender" "org.gnu.Emacs"
                    "-message" message
                    "-activate" "oeg.gnu.Emacs"))
    (add-hook 'org-pomodoro-finished-hook
              (lambda ()
                (notify-osx "Pomodoro completed!" "Time for a break.")))
    (add-hook 'org-pomodoro-break-finished-hook
              (lambda ()
                (notify-osx "Pomodoro Short Break Finished" "Ready for Another?")))
    (add-hook 'org-pomodoro-long-break-finished-hook
              (lambda ()
                (notify-osx "Pomodoro Long Break Finished" "Ready for Another?")))
    (add-hook 'org-pomodoro-killed-hook
              (lambda ()
                (notify-osx "Pomodoro Killed" "One does not simply kill a pomodoro!")))))
