{ pkgs, janet }:
let 
  emptyHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
in 
{
  fetchJpmDeps = { src ? ./., hash ? emptyHash }: 
    pkgs.stdenv.mkDerivation {
      name = "janet-deps";
      inherit src;
      buildInputs = [ 
          janet  
          pkgs.jpm 
          pkgs.git
          pkgs.cacert
        ];
      patchShebangs = false;
      buildPhase = ''
        mkdir $out
        export JANET_PATH=$out
        mkdir ./jpm_tree
        cp --no-preserve=mode -r ${janet}/* ./jpm_tree/
        jpm --local deps 
        rm -rf ./jpm_tree/lib/.cache
        cp -r ./jpm_tree/* $out
      '';
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = hash;
    };
  mkJpmPackage = { name ? "jpm-pkg", src ? ./., jpmDeps, ... }: 
    pkgs.stdenv.mkDerivation {
      name = name;
      inherit src;
      buildInputs = [
        janet
        pkgs.jpm
        pkgs.git
      ];
      buildPhase = ''
        export JANET_PATH=${jpmDeps}
        mkdir $out
        mkdir jpm_tree
        ln -s ${jpmDeps}/* ./jpm_tree/*
        rm ./jpm_tree/lib
        mkdir ./jpm_tree/lib
        echo "hello world"
        ls ./jpm_tree
        ln -s ${jpmDeps}/lib/* ./jpm_tree/lib/*
        jpm --local build
        cp ./build/* $out
      '';
    };
  # TODO make sure this actually works
  mkJpmShell = { depsPath ? ./., buildInputs ? [] }: pkgs.mkShell {
    buildInputs = [ 
        janet
        pkgs.jpm
        pkgs.git
      ] ++ buildInputs;
    shellHook = ''
      export JANET_PATH=${depsPath}
      jpm --local deps
    '';
  };
}
