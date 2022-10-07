{
  description = "Application packaged using poetry2nix";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix";

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    {
      # Nixpkgs overlay providing the application
      overlay = nixpkgs.lib.composeManyExtensions [
        poetry2nix.overlay
        (final: prev: {
          alacritty-colorscheme = prev.poetry2nix.mkPoetryApplication rec {
            projectDir = ./.;
            src = builtins.fetchGit {
              url = "https://github.com/toggle-corp/alacritty-colorscheme";
              ref = "master";
              rev = "4dd944c18aea001a2efdd4954f182a03044189bd";
            };
            pyproject = src + "/pyproject.toml";
            poetrylock = src + "/poetry.lock";
          };
        })
      ];
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ self.overlay ];
        pkgs = builtins.foldl' (acc: overlay: acc.extend overlay)
          nixpkgs.legacyPackages.${system} overlays;
      in rec {
        apps = { alacritty-colorscheme = pkgs.alacritty-colorscheme; };
        packages = pkgs.alacritty-colorscheme;
        defaultPackage = pkgs.alacritty-colorscheme;
        devShells.default = pkgs.mkShell { buildInputs = [ pkgs.poetry ]; };
      }));
}
