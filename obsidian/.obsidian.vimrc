set clipboard=unnamed


nmap j gj
nmap k gk

exmap followLink obcommand editor:follow-link
nmap gd :followLink

exmap openLinkNewSplit obcommand editor:open-link-in-new-split
nmap gD :openLinkNewSplit

exmap insertLink obcommand editor:insert-wikilink
imap <C-l> :insertLink
nmap <C-l> :insertLink
