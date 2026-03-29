# This file provides all the buildable and cacheable packages and
# package outputs in your package set. These are what gets built by CI,
# so if you correctly mark packages as
#
# - broken (using `meta.broken`),
# - unfree (using `meta.license.free`), and
# - locally built (using `preferLocalBuild`)
#
# then your CI will be able to build and cache only those packages for
# which this is possible.

{
  pkgs ? null,
  ...
}:
with builtins;
let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixpkgs_src = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz";
    sha256 = lock.nodes.nixpkgs.locked.narHash;
  };

  flake_pkgs = if pkgs != null then pkgs else import nixpkgs_src { };

  current_system = flake_pkgs.stdenv.hostPlatform;
  lib = flake_pkgs.lib;

  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: builtins.isAttrs p && p ? type && p.type == "derivation";

  isBuildable =
    p:
    let
      isSupported = lib.meta.availableOn current_system p;

      licenseFromMeta = p.meta.license or [ ];
      licenseList = if builtins.isList licenseFromMeta then licenseFromMeta else [ licenseFromMeta ];
      isFree = builtins.all (l: l.free or true) licenseList;

      isNotBroken = !(p.meta.broken or false);
    in
    isSupported && isFree && isNotBroken;

  isCacheable = p: !(p.preferLocalBuild or false);

  flattenPkgs =
    s:
    let
      f =
        p:
        if (builtins.isAttrs p && p.recurseForDerivations or false) then
          flattenPkgs p
        else if isDerivation p then
          if isBuildable p then [ p ] else [ ]
        else
          [ ];
    in
    builtins.concatMap f (builtins.attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs;

  nurAttrs = import ./default.nix { flake_pkgs = flake_pkgs; };

  allValidPkgs = flattenPkgs (
    builtins.listToAttrs (
      map (n: {
        name = n;
        value = nurAttrs.${n};
      }) (builtins.filter (n: !isReserved n) (builtins.attrNames nurAttrs))
    )
  );

in
{
  buildPkgs = allValidPkgs;
  cachePkgs = builtins.filter isCacheable allValidPkgs;

  buildOutputs = builtins.concatMap outputsOf allValidPkgs;
  cacheOutputs = builtins.concatMap outputsOf (builtins.filter isCacheable allValidPkgs);
}
