{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
        };
      in
      rec {
        packages.claude-native-binding = pkgs.callPackage ./claude-native-binding/default.nix { };
        packages.claude-desktop = pkgs.callPackage ./default.nix { claude-native-binding = packages.claude-native-binding; };
        packages.claude-code = pkgs.callPackage ./claude-code/default.nix { }; 
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ ];
          nativeBuildInputs = with pkgs; [
          ];
        };
      }
    );
}
