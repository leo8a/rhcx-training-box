# Getting comfortable with the terminal
dnf install bash-completion vim-enhanced tmux tree -y

cat << EOF > ~/.vimrc
autocmd FileType yaml colo desert
autocmd FileType yaml setlocal ai ts=2 sw=2 et nu cuc
EOF

# config aliases
cat << EOF > ~/.bash_aliases ; . ~/.bash_aliases
alias lt=tree
alias lh='ls -lah'

alias ad='ansible-doc'
alias av='ansible-vault'
alias ag='ansible-galaxy'
alias ap='ansible-playbook'
alias as='ansible-playbook --syntax-check'
EOF
