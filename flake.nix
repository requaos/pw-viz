{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nci.url = "github:yusdacra/nix-cargo-integration";
  inputs.nci.inputs.nixpkgs.follows = "nixpkgs";
  inputs.parts.url = "github:hercules-ci/flake-parts";
  inputs.parts.inputs.nixpkgs-lib.follows = "nixpkgs";

  outputs = inputs @ {
    parts,
    nci,
    ...
  }:
    parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [nci.flakeModule];
      perSystem = {
        pkgs,
        config,
        ...
      }: let
        crateName = "pw-viz";
      in {
        # declare projects
        nci.projects.${crateName}.path = ./.;
        # configure crates
        nci.crates.${crateName} = {
          drvConfig = {
            mkDerivation = {
              overrides = {
                common = prev: {
                  env =
                    prev.env
                    // {
                      LIBCLANG_PATH = prev.pkgs.lib.makeLibraryPath [prev.pkgs.libclang.lib];
                    };
                  buildInputs =
                    (prev.buildInputs or [])
                    ++ [
                      prev.pkgs.libGL
                      prev.pkgs.xorg.libX11
                      prev.pkgs.xorg.libXcursor
                      prev.pkgs.xorg.libXrandr
                      prev.pkgs.xorg.libXi
                      prev.pkgs.xorg.libxcb
                      prev.pkgs.pipewire
                    ];
                  nativeBuildInputs =
                    (prev.nativeBuildInputs or [])
                    ++ [
                      (prev.pkgs.hiPrio prev.pkgs.clang) # needs priority in nix develop shell
                      prev.pkgs.pkg-config
                    ];
                };
                packageMetadata = prev: {
                  runtimeLibs =
                    (prev.runtimeLibs or [])
                    ++ [
                      "libGL"
                      "xorg.libxcb"
                      "pkgs.pipewire"
                    ];
                };
              };
            };
          };
        };
      };
    };
}
