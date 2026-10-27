# Emacs setup on another Mac

Install Homebrew, Apple's Command Line Tools (`xcode-select --install`), and
Emacs Plus 31 first. The Command Line Tools supply `clangd` for C/C++.
Copy this entire directory, including `themes/`, to `~/.emacs.d/`, or link
`~/.emacs.d/init.el` to this checkout's `init.el` as on the original machine.
Do not overwrite an existing init without backing it up.

From the dotfiles checkout root, install the shared system manifest:

```sh
brew bundle --file=Brewfile
```

Neovim and Emacs use the same binaries: `init.el` adds Homebrew, `~/go/bin`
and `~/.cargo/bin` to Emacs `exec-path` and subprocess `PATH`.

The root Brewfile covers the language servers, linters, formatters, runtimes,
and apps used by the dotfiles. Rust tooling comes from rustup; the bootstrap
installs `rust-src` and `rust-analyzer`. Python explicitly uses Pyright; TOML
uses Taplo for both LSP and formatting. Otherwise Eglot's defaults can select
different servers depending on what happens to be installed on each machine.

Start Emacs with network access to install the declared Lisp packages.
Tree-sitter grammars install as the corresponding modes are used. Run
`M-x nerd-icons-install-fonts` once on each machine, then restart Emacs.
Project dependencies and configuration (ESLint, TypeScript, compile_commands.json,
etc.) still belong to each project. Agent-shell agents and Ghostel's native
terminal dependencies have their own setup; this manifest covers language tooling.

This reproduces the tool list, not exact versions: Homebrew and npm install
current releases. It is not a locked snapshot of the original machine.

## Google Calendar and Org

Use [org-gcal](https://github.com/kidd/org-gcal.el) for fetching, creating, and
editing events. It requires a Google Cloud project with Calendar API enabled,
a Desktop OAuth client, and browser authorization on each machine. A work
Google Workspace administrator may need to allow the OAuth application.

Keep each machine's calendar settings in `~/.emacs.d/calendar-local.el`, outside
the shared init. Keep calendar Org files and OAuth tokens out of the dotfiles
repository too. Use the same work account on both machines if you want both
to show the work calendar; or use work credentials only on the work machine.
org-gcal supports one authenticated account per setup, with multiple calendars
that account can access, rather than independently logging into two accounts.

After creating the OAuth client, add this to init.el:

```elisp
(use-package org-gcal
  :commands (org-gcal-fetch org-gcal-sync org-gcal-post-at-point)
  :init
  (load (expand-file-name "calendar-local.el" user-emacs-directory)
        t t))
```

Create `calendar-local.el` locally on each machine:

```elisp
;;; calendar-local.el --- Local calendar settings -*- lexical-binding: t; -*-
(setq org-gcal-client-id "YOUR-DESKTOP-CLIENT-ID.apps.googleusercontent.com"
      org-gcal-client-secret "YOUR-CLIENT-SECRET"
      org-gcal-fetch-file-alist
      '(("YOUR-CALENDAR-ID" . "~/org/calendar/work.org")))
(with-eval-after-load 'org
  (add-to-list 'org-agenda-files "~/org/calendar/work.org"))
```

Create `~/org/calendar/` and an empty `work.org` first. Run `M-x org-gcal-fetch`
and authorize in your browser. Events then appear in `M-x org-agenda`.
Use `M-x org-gcal-sync` to fetch and push edited events, or
`M-x org-gcal-post-at-point` to post a particular event. To create one, add an
Org heading with an active timestamp to the mapped file, then post at that heading.
Editing an invited meeting is subject to your Google Calendar permissions.

Use Google as the shared source between machines, with a separate local Org
mirror on each. Sync pending edits before switching machines; do not also
file-sync the generated calendar Org files between them.

After authentication works, you can refresh periodically by evaluating:

```elisp
(defvar my/calendar-refresh-timer nil)
(when (timerp my/calendar-refresh-timer)
  (cancel-timer my/calendar-refresh-timer))
(setq my/calendar-refresh-timer
      (run-at-time 900 900 #'org-gcal-fetch))
```

This polls every 15 minutes while Emacs runs; it is not push/live synchronization.
Keep posting edits explicit with `org-gcal-sync` or `org-gcal-post-at-point`.
Avoid refreshing over unposted edits. OAuth token encryption may need GnuPG
passphrase setup before background fetching can run unattended; see the upstream
authentication instructions. Test recurring and rescheduled meetings before
relying on the Org view as your only calendar.
