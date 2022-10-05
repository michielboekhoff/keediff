{
  description = "A CLI-tool to diff Keepass (.kdbx) files.";

  inputs = {
    cargo2nix.url = "github:cargo2nix/cargo2nix/unstable";
    flake-utils.follows = "cargo2nix/flake-utils";
    nixpkgs.follows = "cargo2nix/nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, cargo2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ cargo2nix.overlays.default ];
        };

        rustPkgs = pkgs.rustBuilder.makePackageSet {
          rustVersion = "1.64.0";
          packageFun = import ./Cargo.nix;
        };
      in
      {
        packages = {
          keediff = (rustPkgs.workspace.keepass-diff { }).bin;
        };

        formatter = pkgs.nixpkgs-fmt;

        devShells = {
          default = (rustPkgs.workspaceShell {
           packages = with pkgs; [ rust-analyzer clippy ];
          });
        };
      }
    );
}
