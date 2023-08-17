{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.foundry.url = "github:shazow/foundry.nix/monthly";

  outputs = { self, nixpkgs, flake-utils, foundry }:
    flake-utils.lib.eachDefaultSystem (system: 
      let pkgs = import nixpkgs {
        overlays = [ (final: prev: {
              nodejs = prev.nodejs-18_x;
        }) foundry.overlay ];
        inherit system;
      };
    in {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [ pkgs.nodejs-18_x pkgs.nodePackages.pnpm ];
        buildInputs = [ foundry.defaultPackage.${system} ];
      };
    });
}
