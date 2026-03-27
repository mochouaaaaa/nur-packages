{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          flake_pkgs = import nixpkgs { inherit system; };
        }
      );
      packages = forAllSystems (
        system:
        nixpkgs.lib.filterAttrs (
          n: v: nixpkgs.lib.isDerivation v || (nixpkgs.lib.isAttrs v && v.recurseForDerivations or false)
        ) self.legacyPackages.${system}
      );

      devShell = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            nix-update
            common-updater-scripts
          ];
        }
      );
    };
}
