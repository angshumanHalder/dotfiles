#!/bin/sh
# Pick a project and switch kitty to its session: a Neovim tab and a shell tab
# in the project. The session file is created on first use, so new git repos
# under ~/Documents/projects show up without setup. Run by kitty.conf's ctrl+b>p.
export PATH="/opt/homebrew/bin:/Applications/kitty.app/Contents/MacOS:$PATH"
projects="$HOME/Documents/projects"
sessions="$HOME/.local/share/kitty/sessions"

# Running sessions (kitty names a session after its file), listed first with a ●.
open=$(kitten @ ls | jq -r '.[].tabs[].windows[].session_name // empty' | sort -u)

# Lines are "marker<TAB>name<TAB>dir"; fzf shows the marker and dir.
# ~/Documents/projects/a/b -> a-b, so nested projects keep distinct names.
pick=$({
	echo "$HOME/.config"
	fd --hidden --no-ignore --type d --max-depth 4 --exclude node_modules '^\.git$' "$projects" --exec dirname {} | sort
} | open="$open" awk -v config="$HOME/.config" -v projects="$projects" '
	BEGIN { n = split(ENVIRON["open"], a, "\n"); for (i = 1; i <= n; i++) running[a[i]] }
	{
		name = ($0 == config) ? "config" : substr($0, length(projects) + 2)
		gsub("/", "-", name)
		if (name in running) print "●\t" name "\t" $0
		else rest = rest " \t" name "\t" $0 "\n"
	}
	END { printf "%s", rest }
' | fzf --prompt 'project> ' --height 100% --reverse --delimiter '\t' --with-nth 1,3) || exit 0
name=$(printf %s "$pick" | cut -f2)
dir=$(printf %s "$pick" | cut -f3)
file="$sessions/$name.kitty-session"

if [ ! -f "$file" ]; then
	mkdir -p "$sessions"
	cat >"$file" <<EOF
new_tab $name
cd $dir
launch --hold nvim
new_tab $name: shell
cd $dir
launch
focus_tab 0
EOF
fi

exec kitten @ action goto_session "$file"
