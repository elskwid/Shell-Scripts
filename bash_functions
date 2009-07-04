# Functions -------------------------------------------------------------

# Expose the colors to our scripts 

# regular colors
N="\[\033[0m\]"       # no colors (reset)
K="\[\033[0;30m\]"    # black
R="\[\033[0;31m\]"    # red
G="\[\033[0;32m\]"    # green
Y="\[\033[0;33m\]"    # yellow
B="\[\033[0;34m\]"    # blue
M="\[\033[0;35m\]"    # magenta
C="\[\033[0;36m\]"    # cyan
W="\[\033[0;37m\]"    # white

# emphasized (bolded) colors
EMK="\[\033[1;30m\]"
EMR="\[\033[1;31m\]"
EMG="\[\033[1;32m\]"
EMY="\[\033[1;33m\]"
EMB="\[\033[1;34m\]"
EMM="\[\033[1;35m\]"
EMC="\[\033[1;36m\]"
EMW="\[\033[1;37m\]"

# background colors
BGK="\[\033[40m\]"
BGR="\[\033[41m\]"
BGG="\[\033[42m\]"
BGY="\[\033[43m\]"
BGB="\[\033[44m\]"
BGM="\[\033[45m\]"
BGC="\[\033[46m\]"
BGW="\[\033[47m\]"

set_platform() {
  
  if [ `uname -s` = "Linux" ]; then
    export PLATFORM="linux"
  elif [ `uname -s` = "Darwin" ]; then
    export PLATFORM="darwin"
  else
    export PLATFORM="other"
  fi
  
}


include_optional_scripts() {
  
  for file in "$BASH_CUSTOMIZE_DIR"/bash.*
  do
   . $file
  done
  
}

include_local() {
  
  dotlocal="$BASH_CUSTOMIZE_DIR"/bash_customize.local
  
  [ -f $dotlocal ] && . $dotlocal
  
}

set_rubygems_paths() {

  export GEM_HOME=$HOME/.gem/ruby/1.8

  gem env path &> /dev/null
  
  if [ $? -eq 0 ]; then
    local gem_bin="`gem env path | sed -e 's/\:/\/bin\:/' -e 's/$/\/bin/'`"
    export PATH=${gem_bin}:$PATH
  fi
}


# Function for containing PATH customizations
set_custom_path() {
    
  set_rubygems_paths

  # TODO: Replace with case statment or other more better logic
  if [ -d ~/bin ]; then
    export PATH=~/bin:$PATH
  fi

}


##################################################
# Fancy PWD display function
##################################################
# The home directory (HOME) is replaced with a ~
# The last pwdmaxlen characters of the PWD are displayed
# Leading partial directory names are striped off
# /home/me/stuff          -> ~/stuff               if USER=me
# /usr/share/big_dir_name -> ../share/big_dir_name if pwdmaxlen=20
##################################################
bash_prompt_command() {
  
  # How many characters of the $PWD should be kept
  local pwdmaxlen=25
  
  # Indicate that there has been dir truncation
  local trunc_symbol=".."
  local dir=${PWD##*/}
  
  pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))
  
  NEW_PWD=${PWD/#$HOME/\~}
  
  local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))
  if [ ${pwdoffset} -gt "0" ]
  then
    NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
    NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
  fi
    
}


# Function for custom font w/color list so I never have to look them up again
set_titlebar() {

  case $TERM in
   xterm*|rxvt*)
     local TITLEBAR='\[\033]0;\u:${NEW_PWD}\007\]'
      ;;
   *)
     local TITLEBAR=""
      ;;
  esac

}


git_completion() {
  # include .git-completion.bash if it exists
  if [ -f ~/.git-completion.bash ]; then
      . ~/.git-completion.bash
      __git_ps1 "(%s)"
  else
    `ruby -e "print (%x{git branch 2> /dev/null}.grep(/^\*/).first || '').gsub(/^\* (.+)$/, '\1 ')"`
  fi  
}