{ pkgs, janet, jpm, stdenv, ...}:
stdenv.mkDerivation {
  name = "janet2nix";

  buildInputs = [ 
    janet 
    jpm 
  ];

  src = ./.;

  buildPhase = ''
    mkdir ./jpm_tree \
          ./jpm_tree/bin \
          ./jpm_tree/man \
          ./build
    jpm --headerpath=${janet}/include/janet \
        --libpath=${janet}/lib \
        --buildpath=build \
        --binpath=jpm_tree/bin \
        --manpath=jpm_tree/man \
        build
    mkdir -p $out/bin
    cp build/janet2nix $out/bin/janet2nix
    chmod +x $out/bin/janet2nix
  '';
}
