# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
  pkgs25-05 ? import (fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/nixos-25.05.tar.gz";
    sha256 = "sha256-16KkgfdYqjaeRGBaYsNrhPRRENs0qzkQVUooNHtoy2w=";
  }) { inherit (pkgs.stdenv.hostPlatform) system; },
}:
let
  v2dat = pkgs.callPackage ./pkgs/v2dat.nix { };
in
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  inherit v2dat;
  jetbra-free = pkgs.callPackage ./pkgs/jetbra-free { };
  dns-rules = pkgs.callPackage ./pkgs/dns-rules.nix { inherit v2dat; };
  ty = pkgs.callPackage ./pkgs/ty.nix { };

  pot = pkgs25-05.callPackage ./pkgs/pot.nix { };
}
