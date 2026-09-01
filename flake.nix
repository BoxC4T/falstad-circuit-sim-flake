{
  description = "Falstad CircuitJS1 offline simulator";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux"];

    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (system:
        f nixpkgs.legacyPackages.${system});
  in {
    packages = forAllSystems (pkgs: {
      default = pkgs.stdenv.mkDerivation {
        pname = "circuitjs1";
        version = "27.0.0";

        src = pkgs.fetchurl {
          url = "https://www.falstad.com/circuit/offline/circuitjs1-linux64.tgz";
          hash = "sha256-oVH+LVSggGKtaIkVZK05Ctyf7euLTlsQzSOY6cfX3HE=";
        };

        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.copyDesktopItems
        ];

        sourceRoot = "circuitjs1";

        desktopItems = [
          (pkgs.makeDesktopItem {
            name = "circuitjs1";
            desktopName = "Falsad Circuit Simulator";
            exec = "circuitjs1";
            icon = "circuitjs1";
            categories = ["Education" "Science" "Electronics"];
            comment = "Circuit simulator based on CircuitJS1";
            terminal = false;
          })
        ];

        installPhase = ''
          runHook preInstall

          mkdir -p $out/opt/circuitjs1
          cp -r . $out/opt/circuitjs1/

          mkdir -p $out/bin

          makeWrapper \
            $out/opt/circuitjs1/circuitjs1 \
            $out/bin/circuitjs1 \
            --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath (with pkgs; [
            alsa-lib
            atk
            at-spi2-atk
            at-spi2-core
            cairo
            cups
            dbus
            expat
            fontconfig
            freetype
            glib
            gtk3
            libdrm
            libgbm
            libxkbcommon
            nspr
            nss
            pango
            libX11
            libXcomposite
            libXdamage
            libXext
            libXfixes
            libXrandr
            libxcb
          ])}" \
            --add-flags "--no-sandbox"

          runHook postInstall
        '';

        meta = {
          description = "Falstad CircuitJS1 circuit simulator";
          homepage = "https://www.falstad.com/circuit/";
          mainProgram = "circuitjs1";
          platforms = ["x86_64-linux"];
        };
      };
    });

    apps = forAllSystems (pkgs: {
      default = {
        type = "app";
        program = "${self.packages.${pkgs.system}.default}/bin/circuitjs1";
      };
    });
  };
}
