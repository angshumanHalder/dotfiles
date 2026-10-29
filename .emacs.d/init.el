;; init.el --- Emacs configuration -*- lexical-binding: t; -*-
;; Editor tools come from the Brewfile; rust-analyzer and rustfmt from rustup.
(dolist (dir '("/opt/homebrew/bin" "/usr/local/bin" "~/go/bin" "~/.cargo/bin"))
  (setq dir (expand-file-name dir))
  (add-to-list 'exec-path dir)
  (setenv "PATH" (concat dir path-separator (getenv "PATH"))))

;;; Startup
;; Custom writes here instead of init.el. Set before any package install,
;; which saves package-selected-packages through Custom.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)

;;; PACKAGE LIST
(setq package-archives 
      '(("melpa" . "https://melpa.org/packages/")
        ("elpa" . "https://elpa.gnu.org/packages/")))

;;; BOOTSTRAP USE-PACKAGE
;; Packages are activated before init via package-quickstart (early-init.el).
(setq use-package-always-ensure t)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))

;; UI
(setq frame-resize-pixelwise t)

;; Long lines: skip bidi scanning (left-to-right text only); so-long
;; takes over minified files.
(setq-default bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)
(global-so-long-mode 1)
(setq ring-bell-function #'ignore)
(setq display-line-numbers-grow-only t)

(setq display-line-numbers-width-start t)
(setq scroll-conservatively 101
      scroll-step 1
      scroll-margin 2
      auto-window-vscroll nil)
;; Skip fontifying text that scrolls past while keys are still arriving.
(setq fast-but-imprecise-scrolling t
      redisplay-skip-fontification-on-input t
      jit-lock-defer-time 0)

(add-to-list 'display-buffer-alist
	     '("^\\*eldoc"
	       (display-buffer-reuse-window display-buffer-in-side-window)
	       (side . bottom)
	       (window-height . 0.3)))

(add-to-list 'display-buffer-alist
             '("Agenda"
               (display-buffer-in-side-window)
               (side . bottom)
               (window-height . 0.3)))

(add-to-list 'display-buffer-alist
             '("^\\*Help\\*"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom)
               (window-height . 0.3)))

(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)
;; TOML, INI and other config files: conf-mode derives from neither.
(add-hook 'conf-mode-hook #'display-line-numbers-mode)
(add-hook 'org-mode-hook #'org-indent-mode)

(setq org-directory (expand-file-name "~/Documents/org")
      org-agenda-files (list org-directory))
(with-eval-after-load 'org-agenda
  (setq org-agenda-window-setup 'other-window))

;; Resolve the symlink so the theme travels with this configuration.
(add-to-list 'custom-theme-load-path
             (expand-file-name "themes"
                               (file-name-directory
                                (file-truename (or load-file-name user-init-file)))))
(mapc #'disable-theme custom-enabled-themes)
(load-theme 'kanso-ink t)
;; agent-shell hides the comint prompt under its "Me" label rows; a filled
;; prompt face would still paint those rows' ends.
(custom-theme-set-faces
 'kanso-ink
 '(comint-highlight-prompt ((t (:inherit minibuffer-prompt)))))

(use-package doom-modeline
  :custom
  (doom-modeline-height 28)
  (doom-modeline-bar-width 3)
  (doom-modeline-buffer-file-name-style 'relative-to-project)
  (doom-modeline-icon t)
  :config
  (doom-modeline-mode 1))

(use-package ligature
  :ensure t
  :config
  (ligature-set-ligatures 'prog-mode
                          '("->" "=>" "==" "===" "!=" "!==" "<=" ">=" "&&" "||" "::" ":="))
  (global-ligature-mode t))

;; no auto-save, backup, or lock files
(setq auto-save-default nil
      make-backup-files nil
      create-lockfiles nil)

;; gc
(setq gc-cons-threshold (* 128 1024 1024))
(setq read-process-output-max (* 1024 1024 4))


;; terminal
(use-package ghostel
  :ensure t
  :commands (ghostel ghostel-create)
  ;; 60fps: the prompt after a command waits one frame.
  :custom (ghostel-timer-delay 0.016))

(use-package evil-ghostel
  :ensure t
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))

;; Terminals belong to the tabspaces tab: each project tab has its own bottom
;; and full-window terminal, started in the project root. They are named after
;; the tab, not the shell's directory, which follows cd.
(defun my/ghostel-name (kind)
  "Buffer name of the current tab's KIND terminal."
  (format "*ghostel %s: %s*" kind (alist-get 'name (assq 'current-tab (tab-bar-tabs)))))

(defun my/ghostel-create (kind display)
  "Start the current tab's KIND terminal in the project root, shown with DISPLAY."
  (let ((default-directory (or (projectile-project-root) default-directory)))
    (ghostel-create (my/ghostel-name kind) display)))

(defun my/ghostel-toggle-bottom ()
  (interactive)
  (let* ((buffer (get-buffer (my/ghostel-name "bottom")))
         (window (and buffer (get-buffer-window buffer (selected-frame)))))
    (if (and window (eq (window-parameter window 'window-side) 'bottom))
        (delete-window window)
      (if buffer
          (select-window
           (display-buffer-in-side-window
            buffer '((side . bottom) (window-height . 0.3))))
        (my/ghostel-create "bottom" '(display-buffer-in-side-window
                                     (side . bottom)
                                     (window-height . 0.3)))))))

(defun my/ghostel-toggle-full ()
  (interactive)
  (let ((buffer (get-buffer (my/ghostel-name "full"))))
    (cond ((and buffer (eq (current-buffer) buffer)) (switch-to-prev-buffer))
          (buffer (switch-to-buffer buffer))
          (t (my/ghostel-create "full" '(display-buffer-same-window))))))

(defun my/agent-shell-toggle-right ()
  (interactive)
  (require 'agent-shell)
  (let* ((buffer (agent-shell-shell-buffer))
         (window (get-buffer-window buffer (selected-frame))))
    (if (and window (eq (window-parameter window 'window-side) 'right))
        (delete-window window)
      (select-window
       (display-buffer-in-side-window
        buffer '((side . right) (window-width . 0.4)))))))

(defun my/treemacs-toggle-current-project ()
  (interactive)
  (require 'treemacs)
  (if (treemacs-get-local-window)
      (treemacs)
    (treemacs-add-and-display-current-project-exclusively)))

(defun my/eldoc-doc-buffer-focus ()
  (interactive)
  (if (not (and (fboundp 'eglot-managed-p) (eglot-managed-p)))
      (when-let ((win (eldoc-doc-buffer t))) (select-window win))
    (let ((buf (current-buffer)) (pos (point)))
      (unless (eglot-hover-eldoc-function
               (lambda (text &rest props)
                 (when (and (eq buf (window-buffer)) (= pos (point)))
                   (if (string-empty-p (or text ""))
                       (message "No hover documentation at point")
                     (when-let ((win (eldoc-display-in-buffer (list (cons text props)) t)))
                       (select-window win))))))
        (message "Language server does not support hover")))))

;;; Vim Bindings
(use-package evil
  :demand t
  :init
  ;; allows for using cgn
  (setq evil-search-module 'evil-search)
  (setq evil-want-keybinding nil
	;; no vim insert bindings
	evil-undo-system 'undo-redo)
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1)

  ;; escape with C-c
  (evil-define-key 'insert 'global (kbd "C-c") #'evil-normal-state)
  (evil-define-key 'insert 'global (kbd "C-SPC") #'completion-at-point)
  (evil-define-key 'normal 'global (kbd "<escape>") #'evil-ex-nohighlight)
  
  ;; leader key
  (evil-set-leader '(normal visual) (kbd "SPC"))

  ;; finders 
  (evil-define-key 'normal 'global (kbd "<leader>fg") #'consult-ripgrep)
  (evil-define-key 'normal 'global (kbd "<leader>fb") #'consult-buffer)
  (evil-define-key 'normal 'global (kbd "<leader>fr") #'consult-recent-file)
  (evil-define-key 'normal 'global (kbd "<leader>fs") #'consult-imenu)
  (evil-define-key 'normal 'global (kbd "<leader>.") #'find-file)
  (evil-define-key 'normal 'global (kbd "<leader>pp") #'projectile-switch-project)
  (evil-define-key 'normal 'global (kbd "<leader>pa") #'projectile-add-known-project)
  (evil-define-key 'normal 'global (kbd "<leader>pk") #'tabspaces-kill-buffers-close-workspace)
  (evil-define-key 'normal 'global (kbd "<leader>TAB") #'toggle-frame-tab-bar)
  (evil-define-key 'normal 'global (kbd "<leader>ff") #'projectile-find-file)
  (evil-define-key 'normal 'global (kbd "<leader>e") #'my/treemacs-toggle-current-project)

  ;; lsp
  (evil-define-key 'normal 'global (kbd "]d") #'flymake-goto-next-error)
  (evil-define-key 'normal 'global (kbd "[d") #'flymake-goto-prev-error)
  (evil-define-key 'normal 'global (kbd "<leader>fd") #'flymake-show-buffer-diagnostics)
  (evil-define-key 'normal 'global (kbd "<leader>fD") #'flymake-show-project-diagnostics)
  (evil-define-key 'normal 'global (kbd "gd") #'xref-find-definitions)
  (evil-define-key 'normal 'global (kbd "gD") #'eglot-find-declaration)
  (evil-define-key 'normal 'global (kbd "gr") #'xref-find-references)
  (evil-define-key 'normal 'global (kbd "gi") #'eglot-find-implementation)
  (evil-define-key 'normal 'global (kbd "K") #'my/eldoc-doc-buffer-focus)
  (evil-define-key 'normal 'global (kbd "<leader>lr") #'eglot-rename)
  (evil-define-key '(normal visual) 'global (kbd "<leader>la") #'eglot-code-actions)

  ;; git
  (evil-define-key 'normal 'global (kbd "<leader>gg") #'magit-status)
  (evil-define-key 'normal 'global (kbd "<leader>]h") #'diff-hl-next-hunk)
  (evil-define-key 'normal 'global (kbd "<leader>[h") #'diff-hl-previous-hunk)
  (evil-define-key 'normal 'global (kbd "<leader>gp") #'diff-hl-show-hunk)
  (evil-define-key 'normal 'global (kbd "<leader>gs") #'diff-hl-stage-current-hunk)
  (evil-define-key 'normal 'global (kbd "<leader>gr") #'diff-hl-revert-hunk)
  (evil-define-key 'normal 'global (kbd "<leader>gb") #'magit-blame-echo)

  ;; text manipulation
  (evil-define-key 'normal 'global (kbd "<leader>sr") #'project-query-replace-regexp)

  ;; comment (gc{motion}, gcc, visual gc: evil-commentary)
  (evil-define-key 'normal 'global (kbd "gbc") #'my/block-comment-line)
  (evil-define-key 'visual 'global (kbd "gb") #'my/block-comment-region)

  ;; AI
  (evil-define-key 'normal 'global (kbd "<leader>at") #'my/agent-shell-toggle-right)
  (evil-define-key 'normal 'global (kbd "<leader>aT") #'agent-shell)
  (evil-define-key 'normal 'global (kbd "<leader>an")
    (lambda ()
      (interactive)
      (let ((agent-shell-display-action
             '(display-buffer-in-side-window (side . right) (window-width . 0.4))))
        (agent-shell-new-shell))))
  (evil-define-key 'normal 'global (kbd "<leader>aN") #'agent-shell-new-shell)
  (evil-define-key '(normal visual) 'global (kbd "<leader>ac") #'agent-shell-send-region)
  (evil-define-key 'normal 'global (kbd "<leader>af") #'agent-shell-send-file)

  ;; Ghostel
  (evil-define-key 'normal 'global (kbd "<leader>tt")
    #'my/ghostel-toggle-bottom)
  (evil-define-key 'normal 'global (kbd "<leader>tT")
    #'my/ghostel-toggle-full)
  

  ;; TODO search
  (evil-define-key 'normal 'global (kbd "<leader>st") #'my/project-todos)

    

  ;; buffers
  (evil-define-key 'normal 'global (kbd "<leader>bd") #'kill-current-buffer)
  (evil-define-key 'normal 'global (kbd "H") #'previous-buffer)
  (evil-define-key 'normal 'global (kbd "L") #'next-buffer)

  ;; format buffer
  (evil-define-key 'normal 'global (kbd "<leader>lf") #'apheleia-format-buffer)

  ;; Editing keys shared with Neovim
  (evil-define-key 'normal 'global
    (kbd "M-<up>") (lambda () (interactive) (enlarge-window 2))
    (kbd "M-<down>") (lambda () (interactive) (shrink-window 2))
    (kbd "M-<right>") (lambda () (interactive) (enlarge-window-horizontally 2))
    (kbd "M-<left>") (lambda () (interactive) (shrink-window-horizontally 2))
    (kbd "<leader>w") #'save-buffer
    (kbd "<leader>qq") #'save-buffers-kill-terminal
    (kbd "<leader>ld") #'display-local-help)
  (evil-define-key '(normal visual) 'global
    (kbd "M-j") (lambda () (interactive) (my/move-lines 1))
    (kbd "M-k") (lambda () (interactive) (my/move-lines -1)))
  ;; < and > keep the selection, like <gv / >gv.
  (evil-define-key 'visual 'global
    (kbd "<") (lambda () (interactive)
                (call-interactively #'evil-shift-left) (evil-visual-restore))
    (kbd ">") (lambda () (interactive)
                (call-interactively #'evil-shift-right) (evil-visual-restore)))
  ;; C-d/C-u/n/N recenter, like <C-d>zz and nzzzv. Consecutive scrolls put the
  ;; cursor back on the screen row of the first one, undoing the recenter; not
  ;; counting as a scroll makes the next C-d start from the centered cursor.
  (dolist (fn '(evil-scroll-down evil-scroll-up
                evil-ex-search-next evil-ex-search-previous))
    (advice-add fn :after (lambda (&rest _) (recenter) (setq real-this-command #'recenter))))
  )

(use-package evil-matchit
  :after evil
  :config
  (evilmi-load-plugin-rules
   '(html-mode mhtml-mode mhtml-ts-mode html-ts-mode)
   '(template simple html))
  (global-evil-matchit-mode 1))

;; Undo history survives restarts, like Neovim's undofile.
(use-package undo-fu-session
  :config
  (undo-fu-session-global-mode 1))

;; utils
;; The default cleanup stats every entry at startup and hangs on unmounted
;; volumes; dead entries fall off the end of the list instead.
(setq recentf-auto-cleanup 'never)
(recentf-mode 1)
(use-package consult
  :custom
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref))

;; Folding: hideshow handles tree-sitter modes in Emacs 31. Starts unfolded;
;; evil's za/zc/zo/zR/zM drive it, as in Neovim.
(add-hook 'prog-mode-hook #'hs-minor-mode)

;; Block comments like Comment.nvim's gbc / visual gb.
(defun my/block-comment-delimiters ()
  "Block comment open/close strings for the current mode, or nil."
  (cond ((derived-mode-p 'lua-mode 'lua-ts-mode) '("--[[" . "]]"))
        ((and comment-end (not (string-blank-p comment-end)))
         (cons (string-trim comment-start) (string-trim comment-end)))
        ((and comment-start (string-prefix-p "//" (string-trim comment-start)))
         '("/*" . "*/"))))

(defun my/toggle-block-comment (beg end)
  "Wrap the text between BEG and END in a block comment, or unwrap it."
  (pcase-let ((`(,open . ,close)
               (or (my/block-comment-delimiters)
                   (user-error "No block comment syntax in %s" major-mode))))
    (save-excursion
      (let ((start (progn (goto-char beg) (skip-chars-forward " \t\n") (point)))
            (stop (progn (goto-char end) (skip-chars-backward " \t\n") (point))))
        (if (and (>= (- stop start) (+ (length open) (length close)))
                 (string-prefix-p open (buffer-substring-no-properties start stop))
                 (string-suffix-p close (buffer-substring-no-properties start stop)))
            (progn
              (goto-char stop)
              (delete-char (- (length close)))
              (when (eq (char-before) ?\s) (delete-char -1))
              (goto-char start)
              (delete-char (length open))
              (when (eq (char-after) ?\s) (delete-char 1)))
          (goto-char stop)
          (insert " " close)
          (goto-char start)
          (insert open " "))))))

(defun my/block-comment-line ()
  "Toggle a block comment around the current line."
  (interactive)
  (my/toggle-block-comment (line-beginning-position) (line-end-position)))

(defun my/block-comment-region (beg end)
  "Toggle a block comment around the selection."
  (interactive "r")
  (my/toggle-block-comment beg end)
  (evil-exit-visual-state))

(defun my/move-lines (n)
  "Move the current line, or the selected lines, down (N > 0) or up one line."
  (let* ((visual (evil-visual-state-p))
         (first (line-number-at-pos (if visual evil-visual-beginning (point))))
         (last (line-number-at-pos
                (if visual (max evil-visual-beginning (1- evil-visual-end)) (point))))
         (count (line-number-at-pos (point-max))))
    (when (if (> n 0) (< last (1- count)) (> first 1))
      (goto-char (point-min))
      (forward-line (1- first))
      (let ((beg (point)))
        (forward-line (1+ (- last first)))
        (evil-move beg (point) (if (> n 0) (1+ last) (- first 2))))
      (if visual
          ;; evil-move moves the visual markers; rebuild the selection from them.
          (progn (evil-visual-refresh evil-visual-mark evil-visual-point)
                 (indent-region evil-visual-beginning evil-visual-end))
        (indent-according-to-mode)
        (back-to-indentation)))))

(defun my/project-todos ()
  "Search common TODO markers in the current project."
  (interactive)
  (consult-ripgrep nil "#\\b(TODO|FIXME|HACK|NOTE|BUG)\\b"))

(use-package vertico
  :demand t
  :bind (:map vertico-map
	      ("C-w" . backward-kill-word))
  :config
  (vertico-mode 1))

(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind (:map vertico-map
	      ("RET" . vertico-directory-enter)
	      ("DEL" . vertico-directory-delete-char)))

(use-package marginalia
  :init (marginalia-mode))

(use-package editorconfig
  :config
  (editorconfig-mode 1))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode 1)
  (nerd-icons-completion-marginalia-setup))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic)))

(use-package projectile
  :ensure t
  :custom
  ;; doom-modeline already shows the project.
  (projectile-dynamic-mode-line nil)
  (projectile-switch-project-action #'my/projectile-open-tabspace)
  :config
  (projectile-mode +1))

;; Workspaces: each project gets its own tab with its own buffer list, so
;; SPC f b (consult-buffer) only shows that project's buffers. SPC p p opens a
;; project in a new tab or switches to its tab; gt/gT cycle tabs; SPC p k kills
;; the project's buffers and closes its tab.
(use-package tabspaces
  :hook (after-init . tabspaces-mode)
  :custom
  (tabspaces-include-buffers '("*scratch*" "*dashboard*"))
  ;; A new project tab starts on *scratch*, not the previous project's buffer.
  (tab-bar-new-tab-choice "*scratch*")
  ;; Tab bar hidden; SPC TAB toggles it (top of the window). Just the tabs,
  ;; sized to their names, 2px apart: no close/new/history buttons.
  (tab-bar-show nil)
  (tab-bar-format '(tab-bar-format-tabs))
  (tab-bar-auto-width nil)
  (tab-bar-separator (propertize " " 'display '(space :width (2))))
  (tab-bar-close-button-show nil)
  ;; Number the tabs ("1 .config"), the count for {count}gt.
  (tab-bar-tab-hints t)
  (consult-buffer-list-function #'tabspaces-local-buffer-list))

(defun my/projectile-open-tabspace ()
  "Switch to the current project's tab, or open it in a new tab."
  (let* ((root (projectile-project-root))
         (name (projectile-project-name root))
         (open (seq-find (lambda (tab) (equal name (alist-get 'name tab)))
                         (tab-bar-tabs))))
    (tabspaces-switch-or-create-workspace name)
    ;; The new tab shows *scratch*, which is outside the project: find files
    ;; from the project root captured above.
    (unless open
      (let ((default-directory root))
        (projectile-find-file)))))

;; dashboard
(use-package dashboard
  :after projectile
  :custom
  (dashboard-startup-banner 'official)
  (dashboard-banner-logo-title "Emacs")
  (dashboard-center-content t)
  (dashboard-items '((recents . 5)
		     (projects . 5)))
  (dashboard-projects-backend 'projectile)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-set-footer nil)
  (initial-buffer-choice #'dashboard-open)

  :config
  (dashboard-setup-startup-hook))

(use-package treemacs
  :ensure t
  :commands treemacs
  :config
  (treemacs-project-follow-mode t))

(use-package treemacs-evil
  :ensure t
  :after (treemacs evil)
  :config
  ;; Treemacs buffers run in their own evil state, outside the leader map, so
  ;; SPC e needs binding there to close the tree from inside it.
  (evil-define-key 'treemacs treemacs-mode-map
    (kbd "SPC e") #'my/treemacs-toggle-current-project))

(use-package treemacs-projectile
  :ensure t
  :after (treemacs projectile))

(use-package eldoc
  :ensure nil
  :config
  (remove-hook 'eldoc-display-functions #'eldoc-display-in-echo-area))

(use-package which-key
  :ensure nil
  :custom
  (which-key-idle-delay 1.0)
  :config
  (which-key-mode 1))

(use-package embark
  :bind
  (("C-." . embark-act)))

(use-package embark-consult
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Project search & replace, like grug-far: SPC fg, C-. E (export) gives a grep
;; buffer; i edits it (evil-collection), ZZ or :w applies and saves, ZQ cancels.
;; Emacs 31's built-in grep-edit-mode errored when applying edits, so use wgrep.
(use-package wgrep
  :custom
  (wgrep-auto-save-buffer t))

(use-package hl-todo
  :config
  (global-hl-todo-mode 1))

(use-package jinx
  :custom
  (global-jinx-modes '(text-mode conf-mode))
  :hook (emacs-startup . global-jinx-mode))


(use-package indent-bars
  :hook (prog-mode . indent-bars-mode))

;; Built-in automatic bracket and quote pairing.
(use-package elec-pair
  :ensure nil
  :hook (prog-mode . electric-pair-local-mode))

;; AI
(use-package agent-shell
  :commands (agent-shell-send-region agent-shell-send-file)
  :custom-face
  ;; Default is an inverted, boxed badge filled with the keyword color.
  (agent-shell-chat-me-label ((t (:inherit (bold font-lock-keyword-face))))))

(defun my/agent-shell-toggle-full-restore ()
  "Toggle whether resumed agent-shell sessions replay the full chat."
  (interactive)
  (require 'agent-shell)
  (setq agent-shell-session-restore-verbosity
	(if (eq agent-shell-session-restore-verbosity 'full) 'minimal 'full))
  (message "agent-shell restore: %s" agent-shell-session-restore-verbosity))

(defun my/agent-shell-ret ()
  (interactive)
  (if (and (derived-mode-p 'agent-shell-mode 'agent-shell-viewport-view-mode)
           (get-text-property (point) 'agent-shell-ui-state))
      (agent-shell-ui-toggle-fragment)
    (evil-ret)))

(with-eval-after-load 'agent-shell
  (define-key agent-shell-ui-fragment-map (kbd "<return>") #'agent-shell-ui-toggle-fragment)
  (evil-define-key 'normal agent-shell-ui-mode-map (kbd "<return>") #'my/agent-shell-ret)
  )

;; vcs
(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function
   #'magit-display-buffer-same-window-except-diff-v1)
  :config
  (remove-hook 'magit-status-headers-hook #'magit-insert-tags-header))

(use-package diff-hl
  :custom
  (diff-hl-update-async t)
  (diff-hl-flydiff-delay 1)
  :config
  (global-diff-hl-mode 1)
  (require 'diff-hl-flydiff)
  (diff-hl-flydiff-mode 1)
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)
  ;; Pick up commits made outside Emacs (e.g. in a terminal).
  (defun my/diff-hl-refresh (&rest _)
    (with-current-buffer (window-buffer)
      (when diff-hl-mode
        (vc-refresh-state)
        (diff-hl-update))))
  (add-function :after after-focus-change-function #'my/diff-hl-refresh))


;; languages and lsp
;; Emacs 31: open every language in its tree-sitter mode, compiling a missing
;; grammar on first visit. setopt, not setq: the :set function does the remap.
(setopt treesit-enabled-modes t
        treesit-auto-install-grammar 'always)

;; Its own autoloads register the file patterns; .md opens in markdown-ts-mode.
;; Eglot also renders hover documentation with it.
(use-package markdown-mode :defer t)

(defun my/markdown-ts-mode ()
  (require 'markdown-ts-mode)
  (markdown-ts-mode-install-parsers nil)
  (markdown-ts-mode))

(add-to-list 'auto-mode-alist
	     '("\\.\\(md\\|markdown\\)\\'" . my/markdown-ts-mode))

(defun my/set-markup-hidden (hidden)
  (cond
   ((derived-mode-p 'org-mode)
    (unless (and (eq org-hide-emphasis-markers hidden)
                 (eq org-hide-leading-stars hidden))
      (setq-local org-hide-emphasis-markers hidden
                  org-hide-leading-stars hidden)
      (org-restart-font-lock)))
   ((derived-mode-p 'markdown-ts-mode)
    (unless (eq markdown-ts-hide-markup hidden)
      (markdown-ts-toggle-hide-markup)))
   ((derived-mode-p 'markdown-mode)
    (unless (eq markdown-hide-markup hidden)
      (markdown-toggle-markup-hiding (if hidden 1 -1))))))

(defun my/markup-normal-state ()
  (my/set-markup-hidden t))

(defun my/markup-insert-state ()
  (my/set-markup-hidden nil))

(dolist (hook '(org-mode-hook markdown-ts-mode-hook))
  (add-hook hook #'my/markup-normal-state))
(add-hook 'evil-normal-state-entry-hook #'my/markup-normal-state)
(add-hook 'evil-insert-state-entry-hook #'my/markup-insert-state)


;; auto completes and completions
(use-package corfu
  :custom
  (corfu-auto t)
  :init
  (global-corfu-mode))

(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters
	       #'nerd-icons-corfu-formatter))

;; Snippet expansion and placeholder navigation
(use-package yasnippet
  :hook (prog-mode . yas-minor-mode)
  :config
  ;; yas-global-mode did this; the minor mode alone loads no snippet dirs.
  (yas-reload-all))

;; Ready-made snippets for programming languages
(use-package yasnippet-snippets
  :after yasnippet)

;; Additional completion sources
(use-package cape
  :config
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev t)

  ;; Allow fallback completion when Eglot has no matching candidates.
  (with-eval-after-load 'eglot
    (advice-add 'eglot-completion-at-point
		:around #'cape-wrap-nonexclusive)))


(setq eglot-sync-connect 0)
;; Default 0.5s reruns every diagnostic backend on short typing pauses.
(setq flymake-no-changes-timeout 1.5)
(use-package eglot
  :ensure nil ;included with emacs
  :hook ((lua-mode lua-ts-mode python-mode python-ts-mode
		   js-mode js-ts-mode typescript-ts-mode tsx-ts-mode
		   rust-ts-mode go-ts-mode
		   c-mode c-ts-mode c++-mode c++-ts-mode
		   sh-mode bash-ts-mode js-json-mode json-ts-mode
		   yaml-ts-mode conf-toml-mode toml-ts-mode
		   markdown-mode markdown-ts-mode
		   mhtml-mode mhtml-ts-mode html-mode html-ts-mode
		   css-mode css-ts-mode dockerfile-ts-mode) . eglot-ensure)
  :config
  ;; Select the same Python and TOML servers on both machines.
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . ("pyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((conf-toml-mode toml-ts-mode) . ("taplo" "lsp" "stdio")))
  (add-to-list 'eglot-server-programs
               '((markdown-ts-mode :language-id "markdown")
                 . ("marksman" "server")))
  (add-to-list 'eglot-server-programs
	       '(((js-mode :language-id "javascript")
		  (js-ts-mode :language-id "javascript")
		  (typescript-ts-mode :language-id "typescript")
		  (tsx-ts-mode :language-id "typescriptreact"))
		 . ("vtsls" "--stdio")))
  ;; .html opens in mhtml-ts-mode, which derives from js-ts-mode. eglot takes
  ;; the first match and add-to-list prepends, so this must follow vtsls.
  (add-to-list 'eglot-server-programs
	       '(((mhtml-mode :language-id "html")
		  (mhtml-ts-mode :language-id "html")
		  (html-ts-mode :language-id "html"))
		 . ("vscode-html-language-server" "--stdio")))
  :custom
  (eglot-events-buffer-config '(:size 0))
  ;; documentHighlight: a request on every cursor move (slow with vtsls).
  ;; inlayHint: Emacs 31 enables it by default; re-requests after every
  ;; change and repaints the buffer.
  (eglot-ignored-server-capabilities
   '(:documentHighlightProvider :inlayHintProvider)))

(use-package flymake-ruff
  :after eglot
  :config
  (defun my/enable-python-ruff ()
    (when (and (eglot-managed-p)
	       (derived-mode-p 'python-mode 'python-ts-mode))
      (flymake-ruff-load)))

  (add-hook 'eglot-managed-mode-hook #'my/enable-python-ruff))

(use-package flymake-jsts
  :ensure nil
  :vc (:url "https://github.com/orzechowskid/flymake-jsts"
	    :rev :newest)
  :after eglot
  :config
  (setf (alist-get 'eslint flymake-jsts-executable-name-alist)
	"eslint_d")
  (setf (alist-get 'eslint flymake-jsts-project-markers-alist)
        '("eslint.config.js" "eslint.config.mjs" "eslint.config.cjs"
          ".eslintrc" ".eslintrc.js" ".eslintrc.cjs"
          ".eslintrc.json" ".eslintrc.yaml" ".eslintrc.yml"))

  (defun my/enable-js-eslint ()
    (when (and (eglot-managed-p)
               (derived-mode-p 'js-mode 'js-ts-mode
                               'typescript-mode
                               'typescript-ts-mode
                               'tsx-ts-mode)
               (flymake-jsts/get-process-cwd 'eslint (current-buffer)))
      (flymake-jsts-eslint-enable)))

  (add-hook 'eglot-managed-mode-hook #'my/enable-js-eslint))


;; golangci-lint for the open file's package, shown inline like Neovim's
;; nvim-lint. MELPA's flymake-golangci (2019) passes flags that golangci-lint
;; v2 removed. golangci-lint reads files from disk, so it runs on open and
;; save; while the buffer has unsaved edits the last results are kept, on
;; markers so they move with the text. Outside a module it lints the file alone.
(defvar-local my/golangci--proc nil)
(defvar-local my/golangci--issues nil) ; (BEG-MARKER END-MARKER TEXT)...

(defun my/golangci--report (report-fn)
  ;; Fresh diagnostics each time: flymake takes over the objects it is given.
  (funcall report-fn
           (mapcar (lambda (issue)
                     (flymake-make-diagnostic (current-buffer) (marker-position (nth 0 issue))
                                              (marker-position (nth 1 issue)) :warning (nth 2 issue)))
                   my/golangci--issues)))

(defun my/flymake-golangci (report-fn &rest _)
  "Flymake backend running golangci-lint on the current file's package."
  (if (or (buffer-modified-p) (not buffer-file-name))
      (my/golangci--report report-fn)
    (when (process-live-p my/golangci--proc)
      (kill-process my/golangci--proc))
    (let* ((source (current-buffer))
           (file (file-truename buffer-file-name))
           (default-directory (file-name-directory file))
           (gomod (car (ignore-errors (process-lines "go" "env" "GOMOD"))))
           (target (if (member gomod '(nil "" "/dev/null")) file ".")))
      (setq my/golangci--proc
            (make-process
             :name "golangci-lint" :noquery t :connection-type 'pipe
             :buffer (generate-new-buffer " *golangci-lint*")
             :command (list "golangci-lint" "run" "--path-mode=abs" "--show-stats=false"
                            "--output.text.path=stdout" "--output.text.colors=false"
                            "--output.text.print-issued-lines=false" target)
             :sentinel
             (lambda (proc _event)
               (when (memq (process-status proc) '(exit signal))
                 (unwind-protect
                     (when (and (buffer-live-p source)
                                (eq proc (buffer-local-value 'my/golangci--proc source)))
                       (let (issues)
                         (with-current-buffer (process-buffer proc)
                           (goto-char (point-min))
                           (while (re-search-forward
                                   "^\\(.+?\\):\\([0-9]+\\):\\(?:\\([0-9]+\\):\\)? \\(.*\\)$" nil t)
                             (when (equal (file-truename (match-string 1)) file)
                               (let ((region (flymake-diag-region
                                              source (string-to-number (match-string 2))
                                              (and (match-string 3)
                                                   (string-to-number (match-string 3))))))
                                 (push (list (with-current-buffer source (copy-marker (car region)))
                                             (with-current-buffer source (copy-marker (cdr region) t))
                                             (match-string 4))
                                       issues)))))
                         (with-current-buffer source
                           (dolist (old my/golangci--issues)
                             (set-marker (nth 0 old) nil)
                             (set-marker (nth 1 old) nil))
                           (setq my/golangci--issues issues)
                           (my/golangci--report report-fn))))
                   (kill-buffer (process-buffer proc))))))))))

(defun my/enable-go-golangci ()
  (when (and (eglot-managed-p) (derived-mode-p 'go-ts-mode))
    (add-hook 'flymake-diagnostic-functions #'my/flymake-golangci nil t)))
(add-hook 'eglot-managed-mode-hook #'my/enable-go-golangci)

(use-package flymake-hadolint
  :hook ((dockerfile-ts-mode . flymake-hadolint-setup)
	 (dockerfile-ts-mode . flymake-mode)))


(use-package apheleia
  :config
  (setf (alist-get 'prettierd apheleia-formatters)
	'("prettierd" filepath))
  ;; rustfmt on stdin ignores Cargo.toml and parses as Rust 2015, so any
  ;; async fn fails to format. Pass the crate's edition explicitly.
  ;; ponytail: reads only the nearest Cargo.toml; a workspace member with
  ;; `edition.workspace = true' gets the 2021 fallback.
  (defun my/rustfmt-edition ()
    (let* ((dir (locate-dominating-file default-directory "Cargo.toml"))
           (edition (and dir
                         (with-temp-buffer
                           (insert-file-contents (expand-file-name "Cargo.toml" dir))
                           (and (re-search-forward
                                 "^edition *= *\"\\([0-9]+\\)\"" nil t)
                                (match-string 1))))))
      (list "--edition" (or edition "2021"))))
  (setf (alist-get 'rustfmt apheleia-formatters)
	'("rustfmt" "--quiet" "--emit" "stdout" (my/rustfmt-edition)))
  (setq apheleia-mode-alist
	'((lua-mode . stylua)
	  (lua-ts-mode . stylua)
	  (python-mode . ruff)
	  (python-ts-mode . ruff)
	  (js-mode . prettierd)
	  (js-ts-mode . prettierd)
	  (typescript-ts-mode . prettierd)
	  (tsx-ts-mode . prettierd)
	  (json-ts-mode . prettierd)
	  (yaml-ts-mode . prettierd)
	  (conf-toml-mode . taplo)
	  (toml-ts-mode . taplo)
	  (rust-ts-mode . rustfmt)
	  (go-ts-mode . goimports)))
  (apheleia-global-mode 1))


;;; Vim Bindings Everywhere else
(use-package evil-collection
  :after evil
  :config
  (setq evil-want-integration t)
  (evil-collection-init))

(with-eval-after-load 'evil-collection-org-agenda
  (evil-collection-define-key 'normal 'org-agenda-mode-map
    "vt" #'org-agenda-fortnight-view))

(with-eval-after-load 'evil-collection-eglot
  (evil-define-key 'normal 'eglot-mode-map
    (kbd "K") #'my/eldoc-doc-buffer-focus))

;; Surround with mini.surround's keys, shared with Neovim:
;; sa{motion}{char} add (also on a visual selection), sd{char} delete,
;; sr{old}{new} change. `s` becomes a prefix, so evil's `s` (substitute
;; char) is gone; `cl` does the same.
(use-package evil-surround
  :after evil
  :config
  (evil-define-key '(normal visual) 'global (kbd "s") nil)
  (evil-define-key 'normal 'global
    (kbd "sa") #'evil-surround-region
    (kbd "sd") #'evil-surround-delete
    (kbd "sr") #'evil-surround-change)
  (evil-define-key 'visual 'global (kbd "sa") #'evil-surround-region))

;; gc as an operator, like Comment.nvim: gcc, gcip, gcap, visual gc.
(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode 1))

(use-package evil-args
  :after evil
  :config
  (define-key evil-inner-text-objects-map "a" #'evil-inner-arg)
  (define-key evil-outer-text-objects-map "a" #'evil-outer-arg))

;; mini.ai-style lookahead: when the enclosing ( opened on an earlier line,
;; prefer the next ( on the current line.
(defun my/evil-paren-seek (fn &rest args)
  (let ((open (nth 1 (syntax-ppss))))
    (when (and (not (region-active-p))
               (or (null open) (< open (line-beginning-position)))
               (save-excursion
                 (skip-chars-forward "^(" (line-end-position))
                 (eq (char-after) ?\()))
      (skip-chars-forward "^(" (line-end-position))
      (forward-char))
    ;; Evil only extends a visual selection when the text object sees
    ;; `called-interactively-p'; a plain apply would hide that and break vi(.
    (if (called-interactively-p 'any)
        (apply #'funcall-interactively fn args)
      (apply fn args))))
(with-eval-after-load 'evil
  (advice-add 'evil-inner-paren :around #'my/evil-paren-seek)
  (advice-add 'evil-a-paren :around #'my/evil-paren-seek))

