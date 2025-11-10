{ pkgs, janet, janet2nix, jpm, stdenv, ... }:
{  
  name, 
  src, 
  buildInputs ? [ ], 
  extraDeps ? [ ],
}:
let
  deps = import (pkgs.runCommandLocal "run-janet-nix" {
    inherit src;
    buildInputs = [ janet2nix ];
  } ''
    if [ -f "$src/lockfile.jdn" ]; then
      cp $src/lockfile.jdn .
      janet2nix > $out
    else
      echo "[]" > $out
    fi
  '');
  sources = (builtins.map builtins.fetchGit (deps ++ extraDeps));
in stdenv.mkDerivation {
  inherit 
    name 
    src 
    sources;

  buildInputs = buildInputs ++ [ 
    janet 
    jpm 
  ];

  buildPhase = ''
    # localize jpm dependency paths
    export JANET_PATH="$PWD/jpm_tree"
    export JANET_TREE="$JANET_PATH/jpm_tree"
    export JANET_LIBPATH="${pkgs.janet}/lib"
    export JANET_HEADERPATH="${pkgs.janet}/include/janet"
    export JANET_BUILDPATH="$PWD/build"
    export PATH="$PATH:$JANET_TREE/bin"
    mkdir -p \
          $JANET_TREE \
          $JANET_BUILDPATH \
          $PWD/.pkgs

    # fetch packages from the lockfile, mount repos
    for source in $sources; do
      cp -r "$source" "$PWD/.pkgs"
    done
    chmod +w -R "$PWD/.pkgs"

    # install each package
    for source in "$PWD/.pkgs/"*; do
      pushd "$source"
      jpm -l install
      popd
    done

    jpm -l build
    jpm -l install
    mkdir -p $out/bin
    chmod +x $out/bin/$name
  '';
};
