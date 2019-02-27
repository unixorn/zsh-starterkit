XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

main() {
  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  if which tput >/dev/null 2>&1; then
      ncolors=$(tput colors)
  fi
  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi

  # Only enable exit-on-error after the non-critical colorization stuff,
  # which may fail on systems lacking tput or terminfo
  set -e

  # check if git is installed
  command -v git >/dev/null 2>&1 || {
    echo "Error: git is not installed"
    exit 1
  }
  # The Windows (MSYS) Git is not compatible with normal use on cygwin
  if [ "$OSTYPE" = cygwin ]; then
    if git --version | grep msysgit > /dev/null; then
      echo "Error: Windows/MSYS Git is not supported on Cygwin"
      echo "Error: Make sure the Cygwin git package is installed and is first on the path"
      exit 1
    fi
  fi

  if ! command -v zsh >/dev/null 2>&1; then
    printf "${YELLOW}Zsh is not installed!${NORMAL} Please install zsh first!\n"
    exit
  fi

  # install antibody
  if ! command -v curl >/dev/null 2>&1; then
    printf "${YELLOW}curl is not installed!${NORMAL} Please install curl first!\n"
    exit
  fi
  curl -sL git.io/antibody | sh -s
  if ! command -v antibody >/dev/null 2>&1; then
    printf "${YELLOW}antibody did not install successfully!${NORMAL}\n"
    exit
  fi
  source <(antibody init)
  antibody bundle mattmc3/zsh-starterkit
  ANTIBODY_HOME="$(antibody home)"
  STARTERKIT="$ANTIBODY_HOME"/https-COLON--SLASH--SLASH-github.com-SLASH-mattmc3-SLASH-zsh-starterkit

  # backup existing setup
  printf "${BLUE}Looking for existing zsh configs...${NORMAL}\n"
  if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
    printf "${YELLOW}Found ~/.zshrc.${NORMAL} ${GREEN}Backing up to ~/.zshrc.pre-zsh-starterkit${NORMAL}\n";
    mv ~/.zshrc ~/.zshrc.pre-zsh-starterkit;
  fi
  if [ -f ~/.zshenv ] || [ -h ~/.zshenv ]; then
    printf "${YELLOW}Found ~/.zshenv.${NORMAL} ${GREEN}Backing up to ~/.zshenv.pre-zsh-starterkit${NORMAL}\n";
    mv ~/.zshenv ~/.zshenv.pre-zsh-starterkit;
  fi
  if [ -d "${ZDOTDIR}" ] || [ -h "${ZDOTDIR}" ]; then
    printf "${YELLOW}Found ${ZDOTDIR}.${NORMAL} ${GREEN}Backing up to "${ZDOTDIR}".pre-zsh-starterkit${NORMAL}\n";
    mv "${ZDOTDIR}" "${ZDOTDIR}".pre-zsh-starterkit;
  fi

  printf "${BLUE}Using the zsh-starterkit template configs and creating ${ZDOTDIR}${NORMAL}\n"
  cp "$STARTERKIT"/templates/.zshenv ~/.zshenv
  cp -r "$STARTERKIT"/templates/zsh "${ZDOTDIR}"

  # If this user's login shell is not already "zsh", attempt to switch.
  TEST_CURRENT_SHELL=$(basename "$SHELL")
  if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
    # If this platform provides a "chsh" command (not Cygwin), do it, man!
    if hash chsh >/dev/null 2>&1; then
      printf "${BLUE}Time to change your default shell to zsh!${NORMAL}\n"
      chsh -s $(grep /zsh$ /etc/shells | tail -1)
    # Else, suggest the user do so manually.
    else
      printf "I can't change your shell automatically because this system does not have chsh.\n"
      printf "${BLUE}Please manually change your default shell to zsh!${NORMAL}\n"
    fi
  fi

  printf "${GREEN}"
  echo 'Woohoo! zsh-starterkit is now installed!'
  echo ''
  echo "Please look over the ${ZDOTDIR}/.zshrc file to select plugins, themes, and options."
  printf "${NORMAL}"
  env zsh -l
}

main
