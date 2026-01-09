# Bootstrap new workstation with homebrew and yadm
bootstrap:
  #!/usr/bin/env bash
  set -e
  echo "::bootstrap:: Setup dotfiles with YADM"
  brew install yadm
  cd $HOME
  mkdir -p $HOME/bin
  yadm clone --bootstrap --branch dev https://github.com/aussielunix/dotfiles.git
  yadm checkout $HOME
  echo "Logout and back in and then run 'yadm decrypt'"
  echo "::endgroup::"
