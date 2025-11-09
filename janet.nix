{ pkgs, stdenv, lib, janetSrc, ... }:
stdenv.mkDerivation {
    name = "janet";
    src = janetSrc;
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
}
