# GitHub token config
#
# Priority:
# 1. If GITHUBTOKEN is already exported before this file loads, use it.
# 2. Otherwise, use GITHUBTOKEN_HARDCODED below.
# 3. If still %%TOKEN%%, token is considered not configured.
#
# To save and export a token, run:
#   githubtoken ghp_your_token_here
#
GITHUBTOKEN_HARDCODED="%%TOKEN%%"

if [[ -n "${GITHUBTOKEN}" && "${GITHUBTOKEN}" != "%%TOKEN%%" ]]; then
  export GITHUBTOKEN
else
  export GITHUBTOKEN="$GITHUBTOKEN_HARDCODED"
fi

# Syntactic sugar for ANSI escape sequences 
txtblk='\[\e[0;30m\]' # Black - Regular
txtred='\[\e[0;31m\]' # Red
txtgrn='\[\e[0;32m\]' # Green
txtylw='\[\e[0;33m\]' # Yellow
txtblu='\[\e[0;34m\]' # Blue
txtpur='\[\e[0;35m\]' # Purple
txtcyn='\[\e[0;36m\]' # Cyan
txtwht='\[\e[0;37m\]' # White
bldblk='\[\e[01;30m\]' # Black - Bold
bldred='\[\e[01;31m\]' # Red
bldgrn='\[\e[01;32m\]' # Green
bldylw='\[\e[01;33m\]' # Yellow
bldblu='\[\e[01;34m\]' # Blue
bldpur='\[\e[01;35m\]' # Purple
bldcyn='\[\e[01;36m\]' # Cyan
bldwht='\[\e[1;37m\]' # White
unkblk='\[\e[4;30m\]' # Black - Underline
undred='\[\e[4;31m\]' # Red
undgrn='\[\e[4;32m\]' # Green
undylw='\[\e[4;33m\]' # Yellow
undblu='\[\e[4;34m\]' # Blue
undpur='\[\e[4;35m\]' # Purple
undcyn='\[\e[4;36m\]' # Cyan
undwht='\[\e[4;37m\]' # White
bakblk='\[\e[40m\]'   # Black - Background
bakred='\[\e[41m\]'   # Red
badgrn='\[\e[42m\]'   # Green
bakylw='\[\e[43m\]'   # Yellow
bakblu='\[\e[44m\]'   # Blue
bakpur='\[\e[45m\]'   # Purple
bakcyn='\[\e[46m\]'   # Cyan
bakwht='\[\e[47m\]'   # White
txtrst='\[\e[0m\]'    # Text Reset

# screen help
function screen_help {
  printf "\n\
Hotkeys: \n\
\tctrl-a + shift-a \t Rename\n\
\tctrl-a + shift-\" \t List\n\
\tctrl-a + c \t\t Create\n\
\tctrl-a + n \t\t Next\n\
\tctrl-a + p \t\t Previous\n\
\tctrl-a + d \t\t Detach\n\
 \n\
\tctrl-a + | \t\t Split vertical\n\
\tctrl-a + S \t\t Split horizontal\n\
\tctrl-a + tab \t\t Make other tab active\n\
\tctrl-a + esc \t\t Enable scroll\n\

\\\exit to close screen command, add slash to avoid alias\n\
\n"
}

# get screen window list
screenlist() {
    if [[ $1 == -v ]]; then
        local -n _outar="$2"; shift 2
    else
        local _outar
    fi

    _outar=()
    local _string _pointer _maxid=${1:-99}

    case $_maxid in
        '' | *[!0-9]* )
            cat <<EOUsage
Usage:
    $FUNCNAME [-v <varname>] [INT]
       -v varname  Populate array "$varname" with window list
       [INT]       Optional last ID to check for existence, default 99
EOUsage
            return 1
            ;;
    esac

    for ((_pointer=0; _pointer<=_maxid; _pointer++)); do
        _string=$(screen -p "$_pointer" -Q title) &&
            printf -v _outar[_pointer] %s "$_string"
    done

    printf >&2 '\e[A\n\e[K'

    [[ ${_outar[@]@A} != declare\ -a\ _outar=* ]] ||
        for _pointer in ${!_outar[@]}; do
            printf '  %6s: %s\n' "[$_pointer]" "${_outar[_pointer]}"
        done
}

function parse_git_dirty {
  [[ $(git status --porcelain 2> /dev/null) ]] && echo "*"
}

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/(\1$(parse_git_dirty))/"
}

# GitHub token helpers
github_token_is_set() {
  [[ -n "${GITHUBTOKEN}" && "${GITHUBTOKEN}" != "%%TOKEN%%" ]]
}

github_token_status() {
  if github_token_is_set; then
    echo "GITHUBTOKEN is set: ${GITHUBTOKEN:0:8}...${GITHUBTOKEN: -4}"

    if [[ "${GITHUBTOKEN_HARDCODED}" != "%%TOKEN%%" && "${GITHUBTOKEN}" == "${GITHUBTOKEN_HARDCODED}" ]]; then
      echo "Source: hardcoded in ~/.bash_aliases"
    else
      echo "Source: exported environment variable"
    fi
  else
    echo "GITHUBTOKEN is not set"
  fi
}

githubtoken() {
  if [[ -z "$1" ]]; then
    echo "Usage:"
    echo "  githubtoken ghp_your_token_here"
    echo ""
    github_token_status
    return 1
  fi

  local token="$1"

  if ! [ -f "$HOME/.bash_aliases" ]; then
    echo "$HOME/.bash_aliases not found."
    return 1
  fi

  # Save token into .bash_aliases
  if grep -q '^GITHUBTOKEN_HARDCODED=' "$HOME/.bash_aliases"; then
    sed -i "s|^GITHUBTOKEN_HARDCODED=.*|GITHUBTOKEN_HARDCODED=\"$token\"|" "$HOME/.bash_aliases"
  else
    sed -i "1i GITHUBTOKEN_HARDCODED=\"$token\"" "$HOME/.bash_aliases"
  fi

  # Set token for current shell immediately
  export GITHUBTOKEN="$token"
  export GITHUBTOKEN_HARDCODED="$token"

  unset GITHUB_TOKEN_NOTICE_CHECKED
  unset GITBASH_MTIME

  echo "GITHUBTOKEN saved in $HOME/.bash_aliases and exported for this shell."
  github_token_status
  echo "Run: source ~/.bashrc"
}

cleargithubtoken() {
  if ! [ -f "$HOME/.bash_aliases" ]; then
    echo "$HOME/.bash_aliases not found."
    return 1
  fi

  if grep -q '^GITHUBTOKEN_HARDCODED=' "$HOME/.bash_aliases"; then
    sed -i 's|^GITHUBTOKEN_HARDCODED=.*|GITHUBTOKEN_HARDCODED="%%TOKEN%%"|' "$HOME/.bash_aliases"
  fi

  unset GITHUBTOKEN
  export GITHUBTOKEN_HARDCODED="%%TOKEN%%"
  unset GITHUB_TOKEN_NOTICE_CHECKED
  unset GITBASH_MTIME

  echo "Hardcoded GITHUBTOKEN cleared from $HOME/.bash_aliases."
  echo "Run: source ~/.bashrc"
}

github_token_notice_once() {
  if [[ -n "$GITHUB_TOKEN_NOTICE_CHECKED" ]]; then
    return 0
  fi

  export GITHUB_TOKEN_NOTICE_CHECKED=1

  if github_token_is_set; then
    echo "GitHub token configured: ${GITHUBTOKEN:0:8}...${GITHUBTOKEN: -4}"
  else
    echo "GitHub token is not configured."
    echo "To save and export it, run:"
    echo "  githubtoken ghp_your_token_here"
  fi
}

alias github-token-status='github_token_status'
alias github-token='githubtoken'
alias set-github-token='githubtoken'
alias save-github-token='githubtoken'
alias clear-github-token='cleargithubtoken'

# auto reload .bash_aliases on change
check_and_reload_bashrc () {
  if [[ -z "${BASHRC_MTIME}" ]]; then
    if ! [ -f "$HOME/.bash_aliases" ]; then
      touch "$HOME/.bash_aliases"
    fi

    export BASHRC_MTIME="$(date -r "$HOME/.bash_aliases" +%s)"
  else
    if [ "$(date -r "$HOME/.bash_aliases" +%s)" -gt "$BASHRC_MTIME" ]; then
      echo ".bash_aliases changed. re-sourcing.." >&2
      export BASHRC_MTIME="$(date -r "$HOME/.bash_aliases" +%s)"
      . "$HOME/.bashrc"
    fi
  fi

  # Check GitHub version once per shell session, only when token is configured.
  if [[ -z "${GITBASH_MTIME}" ]]; then
    export GITBASH_MTIME="checked"

    if ! github_token_is_set; then
      return 0
    fi

    local github_date
    local github_ts

    github_date=$(curl -s -L \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${GITHUBTOKEN}" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      https://api.github.com/repos/opicron/cloudways_bashrc/commits/main \
      | grep '"date"' | head -n 1 | cut -d'"' -f4)

    if [[ -z "$github_date" ]]; then
      return 0
    fi

    github_ts=$(date -d "$github_date" +%s 2>/dev/null)

    if [[ -z "$github_ts" ]]; then
      return 0
    fi

    if [ "$github_ts" -gt "$BASHRC_MTIME" ]; then
      echo 'github .bash_aliases is more recent, call getgitbash to fetch'
    fi
  fi
}

# load mtime at bash start-up
PROMPT_COMMAND="check_and_reload_bashrc"

# aliases
alias lt='ls --human-readable --size -1 -S --classify'
alias apm='/usr/local/sbin/apm'

# Fetch latest .bash_aliases from GitHub while preserving current token.
getgitbash() {
  local current_token="${GITHUBTOKEN:-%%TOKEN%%}"

  wget -q --show-progress --no-cache \
    https://raw.githubusercontent.com/opicron/cloudways_bashrc/main/.bash_aliases \
    -O "$HOME/.bash_aliases"

  if [[ -n "$current_token" && "$current_token" != "%%TOKEN%%" ]]; then
    if grep -q '^GITHUBTOKEN_HARDCODED=' "$HOME/.bash_aliases"; then
      sed -i "s|^GITHUBTOKEN_HARDCODED=.*|GITHUBTOKEN_HARDCODED=\"$current_token\"|" "$HOME/.bash_aliases"
    else
      sed -i "1i GITHUBTOKEN_HARDCODED=\"$current_token\"" "$HOME/.bash_aliases"
    fi
  fi

  unset GITBASH_MTIME
  unset GITHUB_TOKEN_NOTICE_CHECKED
  source "$HOME/.bashrc"
}

# Claude Code on Cloudways
# Stored outside public_html in private_html.
# This does NOT auto-install. It only shows a one-time notice if Claude is missing.
export CLOUDWAYS_TOOLS_DIR="$HOME/private_html/.cloudways-tools"
export CLAUDE_CONFIG_DIR="$CLOUDWAYS_TOOLS_DIR/claude"
export NPM_CONFIG_PREFIX="$CLOUDWAYS_TOOLS_DIR/npm-global"
export PATH="$NPM_CONFIG_PREFIX/bin:$HOME/.local/bin:$PATH"

claude_install() {
  mkdir -p "$CLAUDE_CONFIG_DIR" "$NPM_CONFIG_PREFIX"

  if command -v claude >/dev/null 2>&1; then
    echo "Claude Code already installed: $(claude --version 2>/dev/null)"
    return 0
  fi

  if ! command -v npm >/dev/null 2>&1; then
    echo "npm is not available. Install or enable Node.js on Cloudways first."
    return 1
  fi

  echo "Installing Claude Code into $NPM_CONFIG_PREFIX ..."
  npm install -g @anthropic-ai/claude-code

  if command -v claude >/dev/null 2>&1; then
    echo "Claude Code installed: $(claude --version 2>/dev/null)"
  else
    echo "Install finished, but claude was not found in PATH."
    echo "Current PATH: $PATH"
    return 1
  fi
}

claude_notice_once() {
  if [[ -n "$CLAUDE_NOTICE_CHECKED" ]]; then
    return 0
  fi

  export CLAUDE_NOTICE_CHECKED=1

  if ! command -v claude >/dev/null 2>&1; then
    echo "Claude Code is not installed. Run: claude-install"
  fi
}

alias claude-install='claude_install'
alias claude-update='npm update -g @anthropic-ai/claude-code'
alias claude-version='claude --version'
alias c='claude'

# Show one-time notices only.
github_token_notice_once
claude_notice_once

# custom screen help
if [ "x$TERM" == "xscreen" ];
then
  # turn off msgbar
  screen -X msgminwait 0
  screen -X msgwait 0
  screen -X vbell off

  # replace exit with screen detach
  alias exit='screen -d'

  # screen ps1 prompt
  PS1="\n${debian_chroot:+($debian_chroot)}"

  # user and screen number-title
  PS1+="${txtpur}[\u${txtrst}:${txtylw}${WINDOW}-\$(screen -Q title)${txtred}\$(parse_git_branch)"

  # end char
  PS1+="${txtpur}]${txtrst}\n"

  # path and $
  PS1+="${txtcyn}\W${txtrst} \$ "

else
  # help screen on first run
  if [[ -z "${BASHRC_MTIME}" ]]; then
    screen_help
  fi

  # replace screen with attach
  alias screen='screen -xR'
fi
