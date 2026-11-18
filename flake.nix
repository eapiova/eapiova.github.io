{
  description = "An academic personal website, written as a total Agda program";

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
      agdaFor = pkgs: pkgs.agda.withPackages (p: [ p.standard-library ]);
      # The site is a function of its build date; for a hermetic build that
      # date is the commit date of the source, not the clock.
      sourceDate =
        let d = self.lastModifiedDate or "19700101000000";
        in "${builtins.substring 0 4 d}-${builtins.substring 4 2 d}-${builtins.substring 6 2 d}";
    in
    {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.stdenv.mkDerivation {
            pname = "academic-site";
            version = "2.0.0";
            src = ./.;

            nativeBuildInputs = [ pkgs.gnumake (agdaFor pkgs) ];
            dontConfigure = true;

            buildPhase = ''
              runHook preBuild
              export HOME=$TMPDIR
              make TODAY=${sourceDate}
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
          default = pkgs.mkShell {
            packages = [
              (agdaFor pkgs)
              pkgs.gnumake
              pkgs.git
              pkgs.python3Minimal
            ];
          };
        });
    };
}
