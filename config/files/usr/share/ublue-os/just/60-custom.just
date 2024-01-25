# Local Just tasks belong here

# update tls ca certificate store
update_aussielunix_ca:
  sudo wget --no-check-certificate https://cacert.hl.valueline.io/aussielunix_Root_CA_168848365996868199089383065266162030969.crt --output-document=/etc/pki/ca-trust/source/anchors/aussielunix_Root_CA_168848365996868199089383065266162030969.crt
  sudo /usr/bin/update-ca-trust

# Bootstrap new workstation with yadm
bootstrap:
  #!/usr/bin/env bash
  set -e
  mkdir $HOME/bin
  curl --silent -fLo $HOME/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm
  chmod a+x $HOME/bin/yadm
  $HOME/bin/yadm clone --bootstrap https://github.com/aussielunix/dotfiles.git
  echo "Running '$HOME/bin/yadm checkout $HOME'"
  $HOME/bin/yadm checkout $HOME
  echo "Logout and back in and then run 'yadm decrypt'"
