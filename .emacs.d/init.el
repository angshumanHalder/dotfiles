;; init.el --- Emacs configuration -*- lexical-binding: t; -*-
(dolist (dir '("/opt/homebrew/bin" "/usr/local/bin" "~/go/bin"
               "~/.local/share/emacs-tools/bin"))
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
  :commands (ghostel ghostel-create))

(use-package evil-ghostel
  :ensure t
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))

(defvar my/ghostel-bottom-buffer nil)

(defun my/ghostel-toggle-bottom ()
  (interactive)
  (let ((window (and (buffer-live-p my/ghostel-bottom-buffer)
                     (get-buffer-window my/ghostel-bottom-buffer (selected-frame)))))
    (if (and window (eq (window-parameter window 'window-side) 'bottom))
        (delete-window window)
      (if (buffer-live-p my/ghostel-bottom-buffer)
          (select-window
           (display-buffer-in-side-window
            my/ghostel-bottom-buffer '((side . bottom) (window-height . 0.3))))
        (setq my/ghostel-bottom-buffer
              (ghostel-create nil '(display-buffer-in-side-window
                                   (side . bottom)
                                   (window-height . 0.3))))))))

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
  (evil-define-key 'normal 'global (kbd "<leader>ff") #'consult-fd)
  (evil-define-key 'normal 'global (kbd "<leader>fg") #'consult-ripgrep)
  (evil-define-key 'normal 'global (kbd "<leader>fb") #'consult-buffer)
  (evil-define-key 'normal 'global (kbd "<leader>fr") #'consult-recent-file)
  (evil-define-key 'normal 'global (kbd "<leader>fs") #'consult-imenu)
  (evil-define-key 'normal 'global (kbd "<leader>.") #'find-file)
  (evil-define-key 'normal 'global (kbd "<leader>pp") #'projectile-switch-project)
  (evil-define-key 'normal 'global (kbd "<leader>pa") #'projectile-add-known-project)
  (evil-define-key 'normal 'global (kbd "<leader>pf") #'projectile-find-file)
  (evil-define-key 'normal 'global (kbd "<leader>op") #'my/treemacs-toggle-current-project)

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

  ;; comment
  (evil-define-key 'normal 'global (kbd "gcc") #'comment-line)
  (evil-define-key 'visual 'global (kbd "gc") #'comment-or-uncomment-region)

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
  (evil-define-key 'normal 'global (kbd "<leader>ot")
    #'my/ghostel-toggle-bottom)
  (evil-define-key 'normal 'global (kbd "<leader>oT")
    (lambda ()
      (interactive)
      (ghostel-create nil '(display-buffer-same-window))))
  

  ;; TODO search
  (evil-define-key 'normal 'global (kbd "<leader>st") #'my/project-todos)

  ;; specific to go
  (evil-define-key 'normal 'global (kbd "<leader>ll") #'my/go-lint-project)
    

  ;; buffers
  (evil-define-key 'normal 'global (kbd "<leader>bk") #'kill-current-buffer)
  (evil-define-key 'normal 'global (kbd "H") #'previous-buffer)
  (evil-define-key 'normal 'global (kbd "L") #'next-buffer)

  ;; format buffer
  (evil-define-key 'normal 'global (kbd "<leader>lf") #'apheleia-format-buffer)

  ;; ghostel keymaps
  (evil-define-key 'normal 'global (kbd "<leader>tt")
    (lambda ()
      (interactive)
      (ghostel-create nil '(display-buffer-in-side-window
			    (side . bottom)
			    (window-height . 0.3)))))

  )

(use-package evil-matchit
  :after evil
  :config
  (evilmi-load-plugin-rules
   '(html-mode mhtml-mode html-ts-mode)
   '(template simple html))
  (global-evil-matchit-mode 1))

;; utils
;; The default cleanup stats every entry at startup and hangs on unmounted
;; volumes; dead entries fall off the end of the list instead.
(setq recentf-auto-cleanup 'never)
(recentf-mode 1)
(use-package consult
  :custom
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref))

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
  :config
  (projectile-mode +1))

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
  :after (treemacs evil))

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
  :commands (agent-shell-send-region agent-shell-send-file))

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
(use-package go-mode :mode "\\.go\\'")
(use-package rust-mode :mode "\\.rs\\'")
(use-package yaml-mode :mode "\\.ya?ml\\'")
;; Its own autoloads register the file patterns; .md opens in markdown-ts-mode.
(use-package markdown-mode :defer t)
(use-package dockerfile-mode
  :mode ("\\(?:Dockerfile\\(?:\\..*\\)?\\|Containerfile\\)\\'"
	 . dockerfile-mode))

(use-package treesit-auto
  :custom
  (treesit-auto-langs '(lua python javascript typescript tsx rust go c cpp bash
			    json yaml toml html css))
  :config
  (treesit-auto-add-to-auto-mode-alist))

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
		   rust-mode rust-ts-mode go-mode go-ts-mode
		   c-mode c-ts-mode c++-mode c++-ts-mode
		   sh-mode bash-ts-mode js-json-mode json-ts-mode
		   yaml-mode yaml-ts-mode conf-toml-mode toml-ts-mode
		   markdown-mode markdown-ts-mode
		   mhtml-mode html-mode html-ts-mode
		   css-mode css-ts-mode) . eglot-ensure)
  :config
  ;; Select the same Python and TOML servers on both machines.
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . ("pyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((conf-toml-mode toml-ts-mode) . ("taplo" "lsp" "stdio")))
  ;; emacs opens .html files in mhtml-mode
  (add-to-list 'eglot-server-programs
	       '((mhtml-mode :language-id "html")
		 . ("vscode-html-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((html-ts-mode :language-id "html")
                 . ("vscode-html-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((markdown-ts-mode :language-id "markdown")
                 . ("marksman" "server")))
  (add-to-list 'eglot-server-programs
	       '(((js-mode :language-id "javascript")
		  (js-ts-mode :language-id "javascript")
		  (typescript-ts-mode :language-id "typescript")
		  (tsx-ts-mode :language-id "typescriptreact"))
		 . ("vtsls" "--stdio")))
  :custom
  (eglot-events-buffer-config '(:size 0))
  ;; Otherwise every cursor move sends a highlight request (slow with vtsls).
  (eglot-ignored-server-capabilities '(:documentHighlightProvider))
  :hook
  (eglot-managed-mode . (lambda () (eglot-inlay-hints-mode -1))))

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


(defun my/go-lint-project ()
  "Run golangci-lint asynchronously at the project root."
  (interactive)
  (let ((default-directory
	 (project-root (project-current t))))
    (compile "golangci-lint run --output.text.colors=false ./...")))

(use-package flymake-hadolint
  :hook ((dockerfile-mode . flymake-hadolint-setup)
	 (dockerfile-mode . flymake-mode)
	 (dockerfile-ts-mode . flymake-hadolint-setup)
	 (dockerfile-ts-mode . flymake-mode)))


(use-package apheleia
  :config
  (setf (alist-get 'prettierd apheleia-formatters)
	'("prettierd" filepath))
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
	  (yaml-mode . prettierd)
	  (yaml-ts-mode . prettierd)
	  (conf-toml-mode . taplo)
	  (toml-ts-mode . taplo)
	  (rust-mode . rustfmt)
	  (rust-ts-mode . rustfmt)
	  (go-mode . goimports)
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

;; Vim-style surround operations.
(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

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
    (apply fn args)))
(with-eval-after-load 'evil
  (advice-add 'evil-inner-paren :around #'my/evil-paren-seek)
  (advice-add 'evil-a-paren :around #'my/evil-paren-seek))

