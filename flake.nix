{
  description = "tinyMediaManager NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        ### modify this to update ###
        version = "5.1.5";
        sha256 = "sha256-ABbfBxJe+DhmghD6Pm82N7UKNdi6ldEIcZ+J7quLp0Y=";
        #############################
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "tinyMediaManager";
          version = version;

          src = pkgs.fetchurl {
            url = "https://archive.tinymediamanager.org/v${version}/tinyMediaManager-${version}-linux-amd64.tar.xz";
            sha256 = sha256;
          };

          nativeBuildInputs = [
            pkgs.autoPatchelfHook
            pkgs.unzip
          ];
          buildInputs = with pkgs; [
            zlib
            glibc
            fontconfig
            alsa-lib
            xorg.libX11
            xorg.libXext
            xorg.libXrender
            xorg.libXtst
            xorg.libXi
            wayland
            gcc13.cc.lib
            libzen
            libmediainfo
            zenity # GUI file dialog
          ];

          buildPhase = ''
          mkdir -p $out/opt/tmm
          cp -r * $out/opt/tmm

          mkdir -p $out/share/applications $out/share/icons/hicolor/128x128/apps
          cp $out/opt/tmm/tmm.png $out/share/icons/hicolor/128x128/apps/tinymediamanager.png
          cat > $out/share/applications/tinymediamanager.desktop << DESKTOP
[Desktop Entry]
Name=tinyMediaManager
GenericName=Media Manager
Comment=Manage and organize your media collection
Exec=$out/bin/tinyMediaManager %u
Terminal=false
Type=Application
Categories=AudioVideo;Video;Utility;
Icon=tinymediamanager
DESKTOP
          chmod 644 $out/share/applications/tinymediamanager.desktop
          '';

          installPhase = ''
          mkdir -p $out/bin
          cat > $out/bin/tinyMediaManager << EOF
#!/bin/sh
export LD_LIBRARY_PATH=${pkgs.libzen}/lib:${pkgs.libmediainfo}/lib:\$LD_LIBRARY_PATH
export PATH=${pkgs.zenity}/bin:\$PATH
cd $out/opt/tmm
exec ${pkgs.zulu23}/bin/java -Djava.library.path=./native -cp "tmm.jar:lib/*" org.tinymediamanager.TinyMediaManager "\$@"
EOF
          chmod +x $out/bin/tinyMediaManager
          '';
        };
      }
    );
}
