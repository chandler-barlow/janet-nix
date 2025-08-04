{ pkgs, makeWrapper, stdenv, lib, ... }:
let 
  # We have to build janet from source
  janet = stdenv.mkDerivation {
    name = "janet";
    src = builtins.fetchGit {
      url = "https://github.com/janet-lang/janet";
    };
    postPatch =
      ''
        substituteInPlace janet.1 \
          --replace /usr/local/ $out/
      ''
      + lib.optionalString stdenv.hostPlatform.isDarwin ''
        # error: Socket is not connected
        substituteInPlace meson.build \
          --replace "'test/suite-ev.janet'," ""
      '';

    nativeBuildInputs = with pkgs;[
      meson
      ninja
    ];

    mesonBuildType = "release";
    mesonFlags = [ "-Dgit_hash=release" ];

  };
  # Building spork from source
  spork = stdenv.mkDerivation {
    name = "spork";
    src = builtins.fetchGit {
      url = "https://github.com/janet-lang/spork";
      rev = "648b9489f8e0741ab499182db9385e7c053a0cbe";
      ref = "master";
    };
    buildInputs = [ janet ];
    buildPhase = ''
      mkdir $out
      janet -l ./bundle -e '(build)'
      export JANET_PATH=$out
      janet -e '(bundle/install ".")'
    '';
  };
in
  stdenv.mkDerivation {
    name = "sporked-janet";
    buildInputs = [
      janet
      makeWrapper
    ];
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${lib.getExe janet} $out/bin/janet \
      --set JANET_PATH ${spork}
    '';
  }
