{ pkgs, stdenv, janet, sporkSrc, ... }:
stdenv.mkDerivation {
  name = "spork";
  src = sporkSrc;
  buildInputs = [ janet ];
  buildPhase = ''
    mkdir $out
    janet -l ./bundle -e '(build)'
    export JANET_PATH=$out
    janet -e '(bundle/install ".")'
  '';
}
