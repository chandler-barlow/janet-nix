{
  description = "janet <> nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    janet = {
      url = "github:janet-lang/janet?ref=master";
      flake = false;
    };
    spork = {
      url = "github:janet-lang/spork?rev=648b9489f8e0741ab499182db9385e7c053a0cbe";
      flake = false;
    };
    jpm = {
      url = "github:janet-lang/jpm";
      flake = false;
    };
    devshell.url = "github:numtide/devshell";
  };

  outputs = inputs@{ self, flake-parts, ... }:
      flake-parts.lib.mkFlake { inherit inputs; } (top@{ config, withSystem, moduleWithSystem, ... }: {
        imports = [
          inputs.flake-parts.flakeModules.easyOverlay
          inputs.devshell.flakeModule
        ];
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        # The documentation specifically says not to consume the overlay
        # by using the provided "final" argument.
        # I don't understand why and I am going to use it until it breaks.
        perSystem = { config, pkgs, final, ... }: 
          let 
            janet = pkgs.callPackage ./pkgs/janet.nix {
              janetSrc = inputs.janet;
            };
            spork = pkgs.callPackage ./pkgs/spork.nix { 
              inherit janet; 
              sporkSrc = inputs.spork;
            };
            janet-utils = pkgs.callPackage ./lib/utils.nix { 
              inherit janet; 
            };
            janet-format = pkgs.callPackage ./pkgs/janet-format.nix {
              inherit spork;
            };
            jpm = pkgs.callPackage ./pkgs/jpm.nix {
              jpmSrc = inputs.jpm;
              inherit janet;   
            };
            jpm-utils = pkgs.callPackage ./lib/jpm-utils.nix {
              inherit janet;
            };
            janet2nix = pkgs.callPackage ./pkgs/janet2nix {
              inherit janet jpm;
            };
            test-app = final.callPackage ./tests/default.nix {};
            mkJanet = pkgs.callPackage ./lib/mkJanet.nix {
              inherit janet jpm janet2nix;
            };
          in
            {
              overlayAttrs = {
                inherit janet jpm;
                janetPackages = {
                  inherit 
                    spork
                    janet-format
                    janet2nix
                    mkJanet;
                  inherit (jpm-utils) 
                    fetchJpmDeps 
                    mkJpmPackage 
                    mkJpmShell;
                  inherit (janet-utils)
                    mkWrappedJanet;
                };
              };
              checks = self.packages // {};
              packages = {
                inherit 
                  janet
                  spork
                  janet-format
                  jpm
                  test-app
                  janet2nix;
              };
              devshells.default = {
                packages = with final; [ 
                  janet
                  jpm
                  stdenv.cc
                  janetPackages.janet-format
                ];
              };
            };
      });
}
