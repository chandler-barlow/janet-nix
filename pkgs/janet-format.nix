{ pkgs, stdenv, spork }:
stdenv.mkDerivation {
  name = "janet-format";
  src = spork;
  installPhase = ''
    mkdir $out
    mkdir $out/bin
    cp ./bin/janet-format $out/bin/janet-format
  '';
}
