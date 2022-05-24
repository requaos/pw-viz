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
        packageMetadata = prev: {
          runtimeLibs = (prev.runtimeLibs or [ ]) ++ [
            "libGL"
            "xorg.libxcb"
            "pkgs.pipewire"
          ];
        };
        crateOverrides = common: prev:
          let
            libclang_path = common.pkgs.lib.makeLibraryPath ([ common.pkgs.libclang.lib ]);
            nbi = [
              (common.pkgs.hiPrio common.pkgs.clang) # needs priority in nix develop shell
              common.pkgs.pkg-config
            ];
            bi = [
              common.pkgs.libGL
              common.pkgs.xorg.libX11
              common.pkgs.xorg.libXcursor
              common.pkgs.xorg.libXrandr
              common.pkgs.xorg.libXi
              common.pkgs.xorg.libxcb
              common.pkgs.pipewire
              common.pkgs.libclang # needed in nix develop shell
            ];
          in
          {
            libspa-sys = prev: {
              LIBCLANG_PATH = libclang_path;
              # buildInputs = (prev.buildInputs or [ ]) ++ [
              #   common.pkgs.pipewire
              # ];
              buildInputs = (prev.buildInputs or [ ]) ++ bi;
              nativeBuildInputs = (prev.nativeBuildInputs or [ ]) ++ nbi;
            };
            pw-viz = prev: {
              LIBCLANG_PATH = libclang_path;
              buildInputs = (prev.buildInputs or [ ]) ++ bi;
              nativeBuildInputs = (prev.nativeBuildInputs or [ ]) ++ nbi;
            };
          };
      };
    };
}


