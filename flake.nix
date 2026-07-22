{
  description = "A durable, Pandoc-built academic personal website";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "academic-site";
            version = "1.0.0";
            src = ./.;

            nativeBuildInputs = [ pkgs.gnumake pkgs.pandoc ];
            strictDeps = true;
            dontConfigure = true;

            buildPhase = ''
              runHook preBuild
              make clean
              make
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p "$out"
              cp -R public/. "$out"/
              runHook postInstall
            '';
          };
        });

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShellNoCC {
            packages = [
              pkgs.gnumake
              pkgs.pandoc
              pkgs.git
              pkgs.python3Minimal
              pkgs.gnutar
              pkgs.gzip
            ];
          };
        });
    };
}
