if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -gx GOPATH /Users/angshumanhalder/go
set -gx EDITOR nvim
set -gx LC_ALL C
set -gx LC_ALL en_US.UTF-8

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

