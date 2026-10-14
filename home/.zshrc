# =============================================================
#  .zshrc — dotfiles Debian
#  Zsh "nativo" optimizado (NO Oh-My-Zsh, sin plugin managers) —
#  port del "Optimized ZSH Configuration" de gh0stzk.
#  apt: zsh zsh-autosuggestions zsh-syntax-highlighting fzf bat eza
# =============================================================

# ── Autodetección rápida de entorno ─────────────────────────
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.config/bspwm/bin:$PATH"
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
export EDITOR="${EDITOR:-nvim}"
export VISUAL="$EDITOR"
export BROWSER="${BROWSER:-firefox}"
export FILEMANAGER="${FILEMANAGER:-thunar}"
export TERMINAL="${TERMINAL:-alacritty}"
export MANPAGER="nvim +Man!"

# ── History ────────────────────────────────────────────────
HISTFILE="$HOME/.cache/zsh_history"
mkdir -p "$HOME/.cache"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY

# ── Options (moderno, liviano) ─────────────────────────────
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt LONG_LIST_JOBS
setopt AUTO_PARAM_SLASH
setopt NO_BEEP

# ── Completion (compinit cacheado — arranque rápido) ───────
autoload -Uz compinit
# regenerar cada 24h
ZSH_COMP="$HOME/.cache/zcompdump"
if [ ! -f "$ZSH_COMP" ] || [ $(find "$ZSH_COMP" -mtime +1 2>/dev/null | wc -l) -gt 0 ]; then
    compinit -C -d "$ZSH_COMP"
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select=1
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/zcompcache"

# ── Plugins apt (cargando directo desde /usr/share) ────────
[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── fzf-tab (gh0stzk usa fzf-tab: apt no lo vende; usamos fzf integrado) ───
command -v fzf >/dev/null && source <(fzf --zsh) 2>/dev/null

# ── Prompt (lite: sin frameworks) ──────────────────────────
PROMPT='%{$fg_bold[blue]%}%2~%{$reset_color%} %{$fg[green]%}$%{$reset_color%} '
RPROMPT='%{$fg[yellow]%}%(?.✔.✖ %? %)%{$reset_color%}'

# ── Aliases (port gh0stzk) ─────────────────────────────────
command -v eza >/dev/null && {
    alias ls='eza --icons --group-directories-first'
    alias l='eza -lb --icons --group-directories-first'
    alias ll='eza -lha --icons --git --group-directories-first'
} || alias ls='ls --color=auto'
command -v bat >/dev/null && alias cat='bat --paging=never'
alias grep='grep --color=auto'
alias update='sudo apt-get update && sudo apt-get upgrade'
alias upgrade='sudo apt-get upgrade'
alias install='sudo apt-get install'
alias search='apt search'
alias df='df -h'
alias free='free -h'
alias mkcd='function _mkcd(){ mkdir -p "$1" && cd "$1" }; _mkcd'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias v='nvim'
alias n='nvim'
alias serve='python3 -m http.server'
alias weather='curl -s wttr.in/\?format=2'
alias ports='ss -tulanp'
alias xz='tar -xzf'
alias xj='tar -xJf'

# ── Keybinds (emacs padrão + history search) ───────────────
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
command -v fzf >/dev/null && bindkey '^R' fzf-history-widget

# ── Fastfetch al abrir (gh0stzk style, light 2 lines) ──────
[ -x /usr/bin/fastfetch ] && fastfetch --logo small

# ── Seguridad básica ───────────────────────────────────────
setopt RM_STAR_WAIT   # confirm al rm * 
