# Portable version of Hamish's Zinit/Powerlevel10k environment.
[[ -o interactive ]] || return
[[ -n ${HAMISH_DEV_SETUP_LOADED:-} ]] && return
typeset -g HAMISH_DEV_SETUP_LOADED=1
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
typeset -U path
path=("$HOME/bin" "$HOME/.local/bin" "$HOME/.cargo/bin" $path)
export NVM_DIR="$HOME/.nvm"
export PYENV_ROOT="$HOME/.pyenv"
path=("$PYENV_ROOT/bin" $path)
[[ -t 0 ]] && export GPG_TTY=$(tty)
HISTFILE=${HISTFILE:-$HOME/.zsh_history}
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
(( $+commands[lsd] )) && alias ls=lsd
alias slep='pmset sleepnow'
alias tillicum='ssh tillicum'
alias klone='ssh klone'
alias klone-check='ssh -O check klone'
alias klone-close='ssh -O exit klone'

if [[ -r "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
  source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit
  zinit ice depth=1
  zinit light romkatv/powerlevel10k
  zinit wait lucid for \
    atinit"zicompinit; zicdreplay" zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' zsh-users/zsh-completions
  zinit wait lucid for OMZP::git
fi
[[ -r "$HOME/.config/hamish-dev/shell/p10k.zsh" ]] && source "$HOME/.config/hamish-dev/shell/p10k.zsh"

if (( $+commands[pyenv] )); then
  pyenv() {
    unfunction pyenv
    eval "$(command pyenv init --path)"
    eval "$(command pyenv init - zsh)"
    pyenv "$@"
  }
fi
# NVM loads only on first invocation, with no recursion if unavailable.
_hamish_load_nvm() {
  unfunction node npm npx nvm _hamish_load_nvm
  local nvm_script="$NVM_DIR/nvm.sh"
  [[ -s "$nvm_script" ]] || nvm_script="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/nvm/nvm.sh"
  [[ -s "$nvm_script" ]] && source "$nvm_script"
}
node() { _hamish_load_nvm; command node "$@"; }
npm() { _hamish_load_nvm; command npm "$@"; }
npx() { _hamish_load_nvm; command npx "$@"; }
nvm() { _hamish_load_nvm; if (( $+functions[nvm] )); then nvm "$@"; else print -u2 'NVM is not installed.'; return 127; fi; }
# Conda is optional. Its environments are not transferred.
for _conda_root in "$HOME/miniforge3" "$HOME/.pyenv/versions/miniforge3" "${HOMEBREW_PREFIX:-/opt/homebrew}/Caskroom/miniforge/base"; do
  if [[ -x "$_conda_root/bin/conda" ]]; then
    export HAMISH_CONDA_ROOT="$_conda_root"
    conda() {
      local hook
      hook=$("$HAMISH_CONDA_ROOT/bin/conda" shell.zsh hook) || return $?
      unfunction conda
      eval "$hook"
      if (( $+functions[conda] )); then conda "$@"; else "$HAMISH_CONDA_ROOT/bin/conda" "$@"; fi
    }
    break
  fi
done
unset _conda_root
[[ -r "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
[[ -r "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/fzf/shell/key-bindings.zsh" ]] && source "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/fzf/shell/key-bindings.zsh"
[[ -r "$HOME/.config/hamish-dev/local.zsh" ]] && source "$HOME/.config/hamish-dev/local.zsh"
