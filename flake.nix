{
  inputs = {
    cargo2nix.url = "github:cargo2nix/cargo2nix/release-0.11.0";
    flake-utils.follows = "cargo2nix/flake-utils";
    nixpkgs.follows = "cargo2nix/nixpkgs";
  };

  outputs = inputs:
    with inputs;
      flake-utils.lib.eachDefaultSystem (
        system: let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [cargo2nix.overlays.default];
          };

          rustPkgs = pkgs.rustBuilder.makePackageSet {
            rustVersion = "1.71.0";
            packageFun = import ./Cargo.nix;

            # Provide the gperfools lib for linking the final rust-analyzer binary
            packageOverrides = pkgs:
              pkgs.rustBuilder.overrides.all
              ++ [
                (pkgs.rustBuilder.rustLib.makeOverride {
                  name = "pw-viz";
                  overrideAttrs = drv: {
                    propagatedNativeBuildInputs =
                      drv.propagatedNativeBuildInputs
                      or []
                      ++ [
                        pkgs.pkg-config
                      ];
                  };
                })
              ];
          };
        in rec {
          packages = {
            pw-viz = rustPkgs.workspace.pw-viz {};
            default = packages.pw-viz;
          };
        }
      );
}
