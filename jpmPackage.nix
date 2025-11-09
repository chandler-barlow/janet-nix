{ pkgs ? import <nixpkgs> {} }:
let 
  emptyHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
in {
  fetchJpmDeps = { src ? ./., hash ? emptyHash }: pkgs.stdenv.mkDerivation {
    name = "janet-deps";
    inherit src;
    buildInputs = 
      with pkgs; [ 
        janet  
        jpm 
        git 
      ];
    buildPhase = ''
      mkdir $out
      export JANET_PATH=$out
      cp -r $src ./.
      jpm deps
    '';
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = hash;
  };
  mkJpmPackage = { name ? "jpm-pkg", src ? ./., jpmDeps }: pkgs.stdenv.mkDerivation {
    name = name;
    inherit src;
    buildInputs = 
      with pkgs; [
        janet
        jpm
        git
      ];
    buildPhase = ''
      export JANET_PATH=${jpmDeps}
      mkdir $out
      jpm build
      cp ./build/* $out
    '';
  };
  mkJpmShell = { depsPath ? ./., buildInputs ? [] }: pkgs.mkShell {
    buildInputs = 
      with pkgs; [ 
        jpm
        janet
        git
      ] ++ buildInputs;
    shellHook = ''
      export JANET_PATH=${depsPath}
      jpm deps
    '';
  };
}
