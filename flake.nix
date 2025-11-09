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
  };

  outputs = inputs@{ self, flake-parts, ... }:
    let 
      mkPackages = pkgs: rec {
        janet = pkgs.callPackage ./janet.nix {
          janetSrc = inputs.janet;
        };
        spork = pkgs.callPackage ./spork.nix { 
          inherit janet; 
          sporkSrc = inputs.spork;
        };
        janet-utils = pkgs.callPackage ./utils.nix { 
          inherit janet; 
        };
        janet-format = pkgs.callPackage ./janet-format.nix {
          inherit spork;
        };
        jpm-utils = pkgs.callPackage ./jpm-utils.nix {
          inherit janet;
        };
      };
    in
      flake-parts.lib.mkFlake { inherit inputs; } (top@{ config, withSystem, moduleWithSystem, ... }: {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        flake = {
          overlays.default = final: prev: 
            let
              ps = mkPackages prev;
            in
              {
                inherit (ps) janet;
                janetPackages = {
                  inherit (ps)
                    spork
                    janet-format;
                  inherit (ps.jpm-utils) 
                    fetchJpmDeps 
                    mkJpmPackage 
                    mkJpmShell;
                  inherit (ps.janet-utils)
                    mkWrappedJanet;
                };
              };
        };
        perSystem = { config, pkgs, ... }: 
          {
            checks = {} // self.packages;
            packages = 
              let
                ps = mkPackages pkgs;
              in
                {
                  inherit (ps)
                    janet
                    spork
                    janet-format;
                };
          };
      });
}
