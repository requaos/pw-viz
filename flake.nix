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
              buildInputs = [
                pkgs.libGL
                pkgs.xorg.libX11
                pkgs.xorg.libXcursor
                pkgs.xorg.libXrandr
                pkgs.xorg.libXi
                pkgs.xorg.libxcb
                pkgs.pipewire
              ];

              shellHook = ''
                export LIBCLANG_PATH=${pkgs.lib.makeLibraryPath [pkgs.libclang.lib]}
              '';

              nativeBuildInputs = [
                (pkgs.hiPrio pkgs.clang) # needs priority in nix develop shell
                pkgs.pkg-config
              ];
            };
          };
        };
      };
    };
}
