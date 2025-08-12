;; Disable startup message
(setq inhibit-startup-message t)

;; UI Tweaks
(scroll-bar-mode -1)  ; Disable scrollbar
(tool-bar-mode -1)    ; Disable toolbar
(tooltip-mode -1)     ; Disable tooltips
(menu-bar-mode -1)    ; Disable menu bar
(set-fringe-mode 10)  ; Add padding to the UI

;; Set up the visible bell
(setq visible-bell t)

;; Ensure installed packages are configured, but not installed dynamically
(setq use-package-always-ensure nil) ;; Nix handles installation

;; Package Manager
(require 'use-package)

;; WHICH-KEY: Discoverable Keybindings
(use-package which-key
  :config
  (which-key-mode))

;; NOTE: The first time you load your configuration on a new machine, you'll
;; need to run the following command interactively so that mode line icons
;; display correctly:
;;
;; M-x all-the-icons-install-fonts
(use-package all-the-icons)

;; Set default font size
(set-face-attribute 'default nil :family "Source Code Pro" :height 120)

;; Distribute window evenly
(add-hook 'window-configuration-change-hook #'balance-windows)

;; Now you can navigate in any direction using C-<arrow>
(when (fboundp 'windmove-default-keybindings)
  (global-set-key (kbd "C-c <left>")  'windmove-left)
  (global-set-key (kbd "C-c <right>") 'windmove-right)
  (global-set-key (kbd "C-c <up>")    'windmove-up)
  (global-set-key (kbd "C-c <down>")  'windmove-down))

;; DOOM-MODELINE: Modern Status Bar
(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 15))

;; MODUS THEMES: Accessible and Beautiful Themes
(use-package modus-themes
  :config
  (load-theme 'modus-operandi t)) ;; Or 'modus-vivendi for dark mode

;; RAINBOW-DELIMITERS: Colorful Parentheses
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; COUNSEL/IVY: Navigation and Search

;; Ensure Ivy and Counsel are loaded
(use-package ivy
  :config
  (ivy-mode 1))  ;; Enable Ivy for better completion

(use-package counsel
  :after ivy
  :config
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-x b" . counsel-ibuffer)
         ("C-s" . swiper)))

(use-package ivy-rich
  :after ivy
  :config
  (ivy-rich-mode 1))  ;; Enable Ivy-Rich for better visuals

;; HELPFUL: Better commands descriptions
(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;; PROJECTILE: Project Management
(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Desktop")
    (setq projectile-project-search-path '("~/Desktop")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package deadgrep
  :ensure t
  :bind (("C-c r" . deadgrep)))

;; MAGIT: Git Integration
(use-package magit
  :bind ("C-x g" . magit-status)
  :custom (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; COMPANY: Autocompletion
(use-package company
  :config
  (global-company-mode))

;; FLYCHECK: Real-time Syntax Checking
(use-package flycheck
  :config
  (global-flycheck-mode))

;; Extra Customizations
(global-set-key (kbd "<escape>") 'keyboard-escape-quit) ;; Make ESC quit prompts
(add-hook 'prog-mode-hook 'display-line-numbers-mode)   ;; Show line numbers in programming modes

;; CLOJURE SETUP

(defun flavio/align-whole-buffer ()
  "Align entire Clojure buffer using clojure-align, then format with cider-format-buffer."
  (when (derived-mode-p 'clojure-mode)
    (save-excursion
      (mark-whole-buffer)
      (clojure-align (region-beginning) (region-end)))
    (when (fboundp 'cider-format-buffer)
      (cider-format-buffer))))

(defun flavio/add-align-on-save ()
  "Add buffer-local after-save-hook to align the Clojure buffer."
  (add-hook 'after-save-hook #'flavio/align-whole-buffer nil t))

(defun flavio/clojure-align-changed-files ()
  "Align all modified .clj files compared to master using clojure-align."
  (interactive)
  (dolist (file (seq-filter (lambda (f) (string-suffix-p ".clj" f))
                            (magit-git-lines "diff" "--name-only" "master...HEAD")))
    (let ((full-path (expand-file-name file (magit-toplevel))))
      (when (file-exists-p full-path)
        (find-file full-path)
        (message "Aligning %s" full-path)
        (mark-whole-buffer)
        (clojure-align (region-beginning) (region-end))
        (save-buffer)))))

(use-package clojure-mode
  :ensure t
  :hook (clojure-mode . flavio/add-align-on-save))

(use-package cider
  :ensure t
  :hook (clojure-mode . cider-mode)
  :config
  (setq cider-repl-display-help-banner nil
        cider-save-file-on-load     t))

(use-package rainbow-delimiters
  :ensure t
  :hook (clojure-mode . rainbow-delimiters-mode))


;; ORG-MODE
(defun flavio/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org)

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode))


;; TREEMACS
(use-package treemacs
  :ensure t
  :config
  (setq treemacs-follow-mode t)        ;; Follow the file in the tree
  (setq treemacs-filewatch-mode t))    ;; Enable file watching

(global-set-key (kbd "C-x t") 'treemacs)
