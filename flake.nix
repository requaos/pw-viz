{
  description = "pw-viz flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    nci.url = "github:yusdacra/nix-cargo-integration";
    nci.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nci, ... }:
    nci.lib.makeOutputs {
      root = ./.;
      overrides = {
        common = prev:
          {
            env = prev.env // {
              LIBCLANG_PATH = prev.pkgs.lib.makeLibraryPath ([ prev.pkgs.libclang.lib ]);
            };
            buildInputs = (prev.buildInputs or [ ]) ++ [
              prev.pkgs.libGL
              prev.pkgs.xorg.libX11
              prev.pkgs.xorg.libXcursor
              prev.pkgs.xorg.libXrandr
              prev.pkgs.xorg.libXi
              prev.pkgs.xorg.libxcb
              prev.pkgs.pipewire
            ];
            nativeBuildInputs = (prev.nativeBuildInputs or [ ]) ++ [
              (prev.pkgs.hiPrio prev.pkgs.clang) # needs priority in nix develop shell
              prev.pkgs.pkg-config
            ];
          };
        packageMetadata = prev: {
          runtimeLibs = (prev.runtimeLibs or [ ]) ++ [
            "libGL"
            "xorg.libxcb"
            "pkgs.pipewire"
          ];
        };
      };
    };
}


