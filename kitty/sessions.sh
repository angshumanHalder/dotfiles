#!/bin/sh
# Running sessions for kitty.conf's ctrl+t>w: an fzf list, most recent first
# (● = current), previewing each session's tabs, programs and folders.
export PATH="/opt/homebrew/bin:/Applications/kitty.app/Contents/MacOS:$PATH"

# A tab's session: its first window that has one (the overlay running this has none).
sname='def sname: [.windows[].session_name | select(. != "")][0] // "";'

if [ "$1" = preview ]; then
	jq -r --arg s "$2" "$sname"'
		.[].tabs[] | select(sname == $s)
		| "\u001b[1;34m\(.title)\u001b[0m",
		  (.windows[] | select(.session_name == $s)
		   | "  \(.foreground_processes[0].cmdline[0] | split("/")[-1] | ltrimstr("-"))"
		     + "  \u001b[2m\(.cwd | sub("^" + env.HOME; "~"))\u001b[0m"),
		  ""' "$SESSIONS_JSON"
	exit
fi

SESSIONS_JSON=$(mktemp)
export SESSIONS_JSON
trap 'rm -f "$SESSIONS_JSON"' EXIT
kitten @ ls >"$SESSIONS_JSON"
cp "$SESSIONS_JSON" "/private/tmp/claude-501/-Users-angshumanhalder--config/183d5cc7-66a9-47ee-8f1b-0b30f103dedf/scratchpad/kitty-debug/$(date +%H%M%S).json" # DEBUG: remove

# Lines are "display<TAB>name"; tabs ordered active, then by recency, then the rest.
pick=$(jq -r "$sname"'
	def pad(n): . + (" " * ([n - length, 1] | max));
	.[] | . as $os
	| [(.tabs[] | select(.is_active) | .id), (.active_tab_history | reverse[]), .tabs[].id]
	| reduce .[] as $id ([]; if index([$id]) then . else . + [$id] end)
	| map(. as $id | $os.tabs[] | select(.id == $id)) as $tabs
	| reduce ($tabs[] | sname) as $s ([]; if $s == "" or index([$s]) then . else . + [$s] end)
	| .[] as $n
	| [$tabs[] | select(sname == $n)] as $t
	| [(if $n == ($tabs[0] | sname) then "\u001b[32m●\u001b[0m" else " " end),
	   ($n | pad(28)),
	   ("\($t | length) tab" + (if ($t | length) > 1 then "s" else "" end) | pad(8)),
	   "\u001b[2m\($t[0].windows[0].cwd | sub("^" + env.HOME; "~"))\u001b[0m"]
	| join(" ") + "\t" + $n
' "$SESSIONS_JSON" | fzf --ansi --prompt 'session> ' --height 100% --reverse \
	--delimiter '\t' --with-nth 1 --border rounded --border-label ' sessions ' \
	--preview "'$0' preview {2}" --preview-window 'right,45%,border-rounded') || exit 0

exec kitten @ action goto_session "$(printf %s "$pick" | cut -f2)"
