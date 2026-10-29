;; early-init.el --- Runs before the first frame and package activation -*- lexical-binding: t; -*-

;; Set frame parameters before the frame exists, so it is laid out once.
;; default-frame-alist also covers emacsclient frames from the daemon.
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(font . "JetBrainsMono Nerd Font Mono-13") default-frame-alist)
(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)
(setq frame-inhibit-implied-resize t)
;; Nerd Font icons (modeline, corfu, marginalia) make cache compaction during
;; GC stall redisplay; keep the caches instead.
(setq inhibit-compacting-font-caches t)

;; Activate packages from one generated file instead of each autoloads file.
;; package.el regenerates it on install/delete; run M-x package-quickstart-refresh
;; after manual changes to elpa/.
(setq package-quickstart t)
