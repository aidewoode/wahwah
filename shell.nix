with import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/e55f77277b59fabd3c220f4870a44de705b1babb.tar.gz") {};

mkShell {
  buildInputs = [
    ruby_2_6
  ];

  shellHook = ''
    export GEM_HOME=$PWD/.gems
    export GEM_PATH=$GEM_HOME
    export PATH=$GEM_HOME/bin:$PATH
  '';
}
