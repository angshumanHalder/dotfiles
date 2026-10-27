# Emacs 31 Performance Optimization — Project Context

## Environment

- macOS on Apple Silicon M2
- Emacs-plus 31, installed through Homebrew
- Native compilation with AOT enabled
- Tree-sitter enabled
- Emacs daemon with GUI client launched through Raycast
- Custom `init.el` using `use-package`
- Evil for modal text editing, Evil Collection for selected major-mode integrations
- No Doom Emacs or Spacemacs

## Primary workflows

1. Multilanguage programming: Rust, Go, TypeScript, JavaScript, Python, C, HTML, CSS, and others.
2. Git using Magit and Diff-HL.
3. Org-mode.
4. Responsive integrated terminal using Ghostel.
5. Project navigation using Projectile, Consult, and Treemacs.
6. AI coding agents using agent-shell and ACP.

## Design philosophy

- Minimal, maintainable configuration.
- Use Vim keybindings primarily for editing, buffer navigation, and file operations.
- Native Emacs keybindings are acceptable elsewhere.
- Prioritize interactive responsiveness over startup benchmarks.
- Avoid installing large frameworks or unnecessary packages.
- Prefer measurable optimizations over speculative changes.

## Findings from previous investigation

### Scrolling

Original configuration used `scroll-conservatively = 101` and experienced noticeable micro-stuttering during viewport scrolling.

Significant improvement was observed with:

```elisp
(setq scroll-conservatively 0
      scroll-step 1
      scroll-margin 2
      auto-window-vscroll nil)
```

### Garbage collection and subprocesses

Responsiveness improved substantially after experimenting with:

```elisp
(setq gc-cons-threshold #x40000000
      read-process-output-max (* 1024 1024 4))
```

These changes were applied together, so their individual contributions are not established.

The 1 GiB GC threshold should be compared with more moderate thresholds and potentially `gcmh`.

### Ghostel

Zsh prompt return previously took approximately 240 ms median.

Disabling Ghostel shell integration improved prompt responsiveness considerably, though it did not eliminate all latency.

Shell integration is currently an area for further evaluation.

### Magit

Git status refreshes remain relatively expensive. Need to distinguish actual Git operation costs, refresh-hook overhead, and package initialization.

### Eglot

First-project startup previously took approximately 1.5–2 seconds, with subsequent operations generally responsive.

RPC event logging was disabled.

### agent-shell

Normal ACP conversations work, including Claude Code after upgrading the Claude ACP adapter.

Full restoration of a large, approximately 14,000-line ACP conversation can freeze the entire Emacs process temporarily. Once restoration finishes, the editor becomes fully responsive.

This is an expensive one-time restoration workload, not evidence of persistent large-buffer scrolling problems.

## Optimization priorities

1. Runtime responsiveness and garbage-collection strategy.
2. Ghostel prompt and terminal latency.
3. Project discovery and switching.
4. Magit refresh overhead.
5. agent-shell session-restoration performance.
6. Startup optimization only where it improves the actual user experience.

## Instructions for Codex

- First inspect the existing `init.el` and any `early-init.el`.
- Do not rewrite the configuration wholesale.
- Do not install Doom, Spacemacs, or another distribution.
- Preserve working features and keybindings.
- Establish baselines before optimization.
- Make one small, measurable change at a time.
- Explain the tradeoffs of each change.
- Ask for permission before introducing new packages.
- Maintain a record of benchmarks and results.
- Prefer reversible changes.
