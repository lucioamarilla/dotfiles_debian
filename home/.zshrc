#  ┌─┐┬  ┬┌─┐┌─┐┌┐┌  - lucioamarilla
#  ├─┤│  │├─┤└─┐│││  - https://github.com/lucioamarilla/dotfiles_debian (rama endeavouros)
#  ┴ ┴┴─┘┴┴ ┴└─┘┘└┘  - zsh "Ubuntu Edition" · oh-my-zsh + agnosterzak · v4.0.2 EOS

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#  ┬  ┬┌─┐┬─┐┌─┐
#  └┐┌┘├─┤├┬┘└─┐
#   └┘ ┴ ┴┴└─└─┘
export EDITOR='geany'
export VISUAL="$EDITOR"
export BROWSER='firefox'
export FILEMANAGER='thunar'
export IMGVIEWER='viewnior'
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
export SUDO_PROMPT="Contraseña para %u: "
export BAT_THEME="base16"

if [ -d "$HOME/.local/bin" ];
  then PATH="$HOME/.local/bin:$PATH"
fi

#  ┬  ┌─┐┌─┐┌┬┐  ┌─┐┌┐┌┌─┐┬┌┐┌┌─┐
#  │  │ │├─┤ ││  ├┤ ││││ ┬││││├┤
#  ┴─┘└─┘┴ ┴─┴┘  └─┘┘└┘└─┘┴┘└┘└─┘
# oh-my-zsh — paquete Arch (/usr/share/oh-my-zsh) o clone en $HOME.
if [ -d "$HOME/.oh-my-zsh" ]; then
  export ZSH="$HOME/.oh-my-zsh"
elif [ -d "/usr/share/oh-my-zsh" ]; then
  export ZSH="/usr/share/oh-my-zsh"
else
  echo "zshrc: oh-my-zsh no encontrado (pacman -S oh-my-zsh) — prompt simplified"
fi

if [[ -n "${ZSH:-}" ]]; then
  # Custom user dir (themes/plugins) fuera del árbol del paquete.
  export ZSH_CUSTOM="$HOME/.config/zsh/custom"

  # El theme agnosterzak vive en $ZSH_CUSTOM/themes/ (lo copia el installer).
  # OMZ resuelve en este orden: $ZSH_CUSTOM/themes → $ZSH_CUSTOM → $ZSH/themes
  ZSH_THEME="agnosterzak"
  ZSH_COMPDUMP="$HOME/.config/zsh/zcompdump"
  DISABLE_AUTO_UPDATE="true"                        # pacman gestiona OMZ

  plugins=( git )

  source $ZSH/oh-my-zsh.sh
fi

#  ┌┬┐┬ ┬  ┌─┐  ┌┬┐┌─┐┌─┐┌─┐┌─┐
#   │ ├─┤  ├─┤  │ │ ┬ ├─┤│ ││
#   ┴ ┴ ┴  ┴ ┴  ┴  └─┘ ┴ ┴└─┘└─┘
# Plugins de repos oficiales (post-omz; no como plugins de OMZ para no re-clonar):
source_plugin() { [ -e "$1" ] && source "$1"; }
source_plugin /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  || source_plugin /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source_plugin /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  || source_plugin /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source_plugin /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh \
  || source_plugin /usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# fzf-tab — vendored; el installer lo pasa a $ZSH_CUSTOM/plugins (OMZ lo carga)
# y si no se cargó (sin OMZ / plugin faltante) cae al fallback vendido.
if ! (( $+functions[fzf-tab-complete] )); then
  source_plugin "$ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.zsh" \
    || source_plugin "$HOME/.config/zsh/fzf-tab/fzf-tab.zsh"
fi

zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list \
		'm:{a-zA-Z}={A-Za-z}' \
		'+r:|[._-]=* r:|=*' \
		'+l:|=*'
zstyle ':fzf-tab:*' fzf-flags --style=full --height=90% --pointer '>' --gutter ' ' \
                    --color 'pointer:green:bold,bg+:-1:,fg+:green:bold,info:blue:bold,marker:yellow:bold,hl:gray:bold,hl+:gray:bold' \
                    --input-label ' Search ' --color 'input-border:blue,input-label:blue:bold' \
                    --list-label ' Results ' --color 'list-border:green,list-label:green:bold' \
                    --preview-label ' Preview ' --preview-label-pos '27:bottom' --color 'preview-border:magenta,preview-label:magenta:bold'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --icon always --color always $realpath'
zstyle ':fzf-tab:complete:lsd:*' fzf-preview 'lsd -1 --icon always --color always $realpath'
zstyle ':fzf-tab:complete:bat:*' fzf-preview 'bat --color=always --theme=base16 $realpath'
zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
zstyle ':fzf-tab:*' accept-line enter

#  ┬ ┬┬┌─┐┌┬┐┌─┐┬─┐┬ ┬
#  ├─┤│└─┐ │ │ │├┬┘└┬┘
#  ┴ ┴┴└─┘ ┴ └─┘┴└─ ┴
HISTFILE=~/.config/zsh/zhistory
HISTSIZE=5000
SAVEHIST=5000
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

#  ┌─┐┌─┐┬ ┬  ┌─┐┌─┐┌─┐┬    ┌─┐┌─┐┌┬┐┬┌─┐┌┐┌┌─┐
#  ┌─┘└─┐├─┤  │  │ ││ ││    │ │├─┘ │ ││ ││││└─┐
#  └─┘└─┘┴ ┴  └─┘└─┘└─┘┴─┘  └─┘┴   ┴ ┴└─┘┘└┘└─┘
setopt AUTOCD              # change directory just by typing its name
setopt MENU_COMPLETE       # Automatically highlight first element of completion menu
setopt LIST_PACKED		   # The completion menu takes less space.
setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD    # Complete from both ends of a word.

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[3~' delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

#  ┌─┐┬  ┬ ┬┌─┐┬┌┐┌┌─┐
#  ├─┘│  │ ││ ┬││││└─┐
#  ┴  ┴─┘└─┘└─┘┴┘└┘└─┘
function xterm_title_precmd () {
	print -Pn -- '\e]2;%n@%m %~\a'
	[[ "$TERM" == 'screen'* ]] && print -Pn -- '\e_\005{g}%n\005{-}@\005{m}%m\005{-} \005{B}%~\005{-}\e\\'
}

function xterm_title_preexec () {
	print -Pn -- '\e]2;%n@%m %~ %# ' && print -n -- "${(q)1}\a"
	[[ "$TERM" == 'screen'* ]] && { print -Pn -- '\e_\005{g}%n\005{-}@\005{m}%m\005{-} \005{B}%~\005{-} %# ' && print -n -- "${(q)1}\e\\"; }
}

if [[ "$TERM" == (kitty*|alacritty*|tmux*|screen*|xterm*) ]]; then
	add-zsh-hook -Uz precmd xterm_title_precmd
	add-zsh-hook -Uz preexec xterm_title_preexec
fi

#  ┌─┐┬  ┬┌─┐┌─┐
#  ├─┤│  │├─┤└─┐
#  ┴ ┴┴─┘┴┴ ┴└─┘
# alias update: pacman + AUR (helper autodetectado — yay es el default de EOS)
if command -v yay >/dev/null 2>&1; then
  alias update="yay -Syu"
elif command -v paru >/dev/null 2>&1; then
  alias update="paru -Syu"
else
  alias update="sudo pacman -Syu"
fi

alias grub-update="sudo grub-mkconfig -o /boot/grub/grub.cfg"

alias music="ncmpcpp"

alias cat="bat --theme=base16"

# lsd (tu Ubuntu) reemplaza a eza en los aliases
alias ls='lsd'
alias l='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'
alias code="code --disable-gpu"

#  ┌─┐┬─┐┬  ┌─┐┌┐┌┌─┐┬┌┐┌┌─┐┬  ┌─┐
#  ┴ ┴├┬┘│  │  │││││││││││└─┐
#  ┴ ┴┴└─┴─┘└─┘┴┘└┘┘└┘┴┘┴┴┘┘└┘┴  ┴
# Extras dev de tu Ubuntu — con guards: no-op si el dir no existe en EOS.
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

for _d in "$HOME/.opencode/bin" "/opt/flutter/bin" "$HOME/.kimi-code/bin" \
          "$HOME/.kilo/bin" "$HOME/.spicetify" "$HOME/go/bin"; do
  [ -d "$_d" ] && PATH="$_d:$PATH"
done
unset _d
export LIBVIRT_DEFAULT_URI="qemu:///system"

#  ┌─┐┌┐┌┌┬┐┬ ┬  ┌┐┌┌─┐┌┬┐┌─┐┌─┐  ┌┬┐┬┬  ┌─┐┌┬┐
#  ├─┴┤│││ │ ├─┤  │ ││ │ ││ ┬├─┤   │ ├┼├─┤││││││
#  ┴ ┴┴┘└┘ ┴ ┴ ┴  ┴┘└┘└─┘─┴┘┴ ┴─┘   ┴ ┴┴┴ ┴┴ ┴┴ ┴
# pokemon-colorscripts + fastfetch — INSTALADOS y por ahora DESACTIVADOS.
#
# Tu Ubuntu corre esto en cada apertura de terminal. Para activarlo en EOS
# descomentá el bloque de abajo:
#
# if command -v pokemon-colorscripts >/dev/null 2>&1 && command -v fastfetch >/dev/null 2>&1; then
#   pokemon-colorscripts --no-title -s -r | \
#     fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc \
#     --logo-type file-raw --logo-height 10 --logo-width 5 --logo -
# fi
#
# Alternativa compacta (sin pokemon):
#   fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc
#
# Nota: pokemon-colorscripts (AUR) necesita python3; fastfetch está en repos.
