set clipboard=unnamed


nmap j gj
nmap k gk

exmap followLink obcommand editor:follow-link
nmap gd :followLink<CR>

exmap openLinkNewSplit obcommand editor:open-link-in-new-split
nmap gD :openLinkNewSplit<CR>

exmap insertLink obcommand editor:insert-wikilink
imap <C-l> :insertLink<CR>
nmap <C-l> :insertLink<CR>
