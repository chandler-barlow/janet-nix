{ stdenv, lib, makeWrapper, janet, ... } :
{
  # Point janet to some set of packages
  mkWrappedJanet = { janetDeps, name ? "wrapped-janet" }:
    stdenv.mkDerivation {
      inherit name;
      buildInputs = [
        janet
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
