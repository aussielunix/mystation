# Bootstrap new workstation with homebrew and yadm
bootstrap:
  #!/usr/bin/env bash
  set -e
  echo "::bootstrap:: Install Homebrew"
  /usr/bin/mkdir -p /tmp/homebrew
  /usr/bin/sudo /usr/bin/mkdir -p /var/home/linuxbrew
  /usr/bin/sudo /usr/bin/chown -R 1000:1000 /var/home/linuxbrew
  /usr/bin/tar --zstd -xvf /usr/share/homebrew.tar.zst -C /tmp/homebrew
  /usr/bin/cp -R -n /tmp/homebrew/home/linuxbrew/.linuxbrew /var/home/linuxbrew
  /usr/bin/sudo /usr/bin/chown -R 1000:1000 /var/home/linuxbrew
  /usr/bin/rm -rf /tmp/homebrew
  /usr/bin/sudo /usr/bin/touch /etc/.linuxbrew
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  brew install gcc
  echo "::endgroup::"
  echo "::bootstrap:: Setup dotfiles with YADM"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  brew install yadm
  cd $HOME
  mkdir -p $HOME/bin
  yadm clone --bootstrap --branch dev https://github.com/aussielunix/dotfiles.git
  yadm checkout $HOME
  echo "Logout and back in and then run 'yadm decrypt'"
  echo "::endgroup::"
