# Janet NIX

Barebones functionality for creating a janet project in nix.
Allows for building janet projects that depend on spork currently.

The goal here is to eventually support various janet modules and deps.
Currently only spork is supported. 
  
Usage

```nix
{ pkgs ? import <nixpkgs> {} }:
let
	janetWrapped = pkgs.callPackage ./janet.nix {};
in
	pkgs.mkShell {
		buildInputs = [ janetWrapped ];
		shellHook = ''
			echo "It's janet time!"
		'';
	}
```
