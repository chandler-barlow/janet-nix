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

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (top@{ config, withSystem, moduleWithSystem, ... }: {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem = { config, pkgs, ... }: 
        let 
          janet = pkgs.callPackage ./janet.nix {
            janetSrc = inputs.janet;
          };
          spork = pkgs.callPackage ./spork.nix { 
            inherit janet; 
            sporkSrc = inputs.spork;
          };
          janet-utils = pkgs.callPackage ./utils.nix {};
          janet-format = pkgs.callPackage ./janet-format.nix {
            inherit spork;
          };
        in
          {
            packages = {
              inherit janet;
              inherit spork;
              inherit janet-utils;
              inherit janet-format;
            };
          };
    });
}
