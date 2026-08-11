{
  description = "pi extension that exposes agent-browser as a native tool for browser automation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    lib = nixpkgs.lib;
    forEachSystem = lib.genAttrs systems;
    pkgsFor = system: nixpkgs.legacyPackages.${system};
  in {
    devShells = forEachSystem (system: let
      pkgs = pkgsFor system;
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          nodejs_22
          typescript
        ];
      };
    });

    packages = forEachSystem (system: let
      pkgs = pkgsFor system;
    in {
      default = pkgs.buildNpmPackage {
        pname = "pi-agent-browser-native";
        version = "0.4.1";

        src = ./.;

        npmDepsHash = "sha256-IupZcK82RGCd5T1ckRax86Y1VJd+ABhZiGREb+IjfjA=";

        npmBuildScript = "build";
        makeCacheWritable = true;

        installPhase = ''
          mkdir -p $out
          cp -r dist $out/
        '';

        meta = {
          description = "pi extension that exposes agent-browser as a native tool for browser automation";
          license = lib.licenses.mit;
          platforms = lib.platforms.all;
        };
      };
    });
  };
}
