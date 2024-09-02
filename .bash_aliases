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

\\\exit to close screen command (add slash to avoid alias)\n\
\n"
}

# get screen window list
screenlist() {
    if [[ $1 == -v ]]; then
        local -n _outar="$2";shift 2
        else local _outar
    fi
    _outar=()
    local _string _pointer _maxid=${1:-99}
    case $_maxid in
        '' | *[!0-9]* )
            cat <<EOUsage
Usage:
    $FUNCNAME [-v <varname>] [INT]
       -v varname  Populate array "$varname" with window list
       [INT]       Optional last ID to check for existence (default 99)
EOUsage
            return 1
            ;;
    esac

    for ((_pointer=0;_pointer<=_maxid;_pointer++)); do
        _string=$(screen -p $_pointer -Q title) &&
            printf -v _outar[_pointer] %s "$_string"
    done
    printf >&2 '\e[A\n\e[K'
    [[ ${_outar[@]@A} != declare\ -a\ _outar=* ]] ||
        for _pointer in ${!_outar[@]};do
            printf '  %6s: %s\n' "[$_pointer]" "${_outar[_pointer]}"
        done
}

function parse_git_dirty {
  [[ $(git status --porcelain 2> /dev/null) ]] && echo "*"
}

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/(\1$(parse_git_dirty))/"
}

# listing
alias lt='ls --human-readable --size -1 -S --classify'


# custom screen help
if [ "x$TERM" == "xscreen" ];
then
  #turn off msgbar
  screen -X msgminwait 0
  screen -X msgwait 0
  screen -X vbell off

  #replace exit with screen detach
  alias exit='screen -d'

  screen_help

  # screen ps1 prompt
  PS1="\n${debian_chroot:+($debian_chroot)}"

  # user and screen number-title
  PS1+="${txtpur}[\u${txtrst}:${txtylw}${WINDOW}-\$(screen -Q title)${txtred}\$(parse_git_branch)"

  # end char
  PS1+="${txtpur}]${txtrst}\n"

  # path and $
  PS1+="${txtcyn}\W${txtrst} \$ "

else
  #replace screen with attach
  alias screen='screen -R'
fi