{ pkgs ? import <nixpkgs> {}, stdenv, lib, makeWrapper, ... } :
{
  # Point janet to some set of packages
  mkWrappedJanet = { janetDeps, name ? "wrapped-janet" }:
    stdenv.mkDerivation {
      inherit name;
      buildInputs = [
        pkgs.janet
        makeWrapper
      ];
      phases = [ "installPhase" ];
      installPhase = ''
        mkdir -p $out/bin
        makeWrapper ${lib.getExe janet} $out/bin/janet \
        --set JANET_PATH ${janetDeps}
      '';
    };
}
