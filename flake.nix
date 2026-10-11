{
  description = "NixOS config shrky";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mugen-shell = {
      url = "github:tmy7533018/mugen-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, mugen-shell, ... }:
  let
    system = "x86_64-linux";

    mugen-shell-bright = nixpkgs.legacyPackages.${system}.runCommand "mugen-shell-bright" { } ''
      cp -r ${mugen-shell}/shell $out
      chmod -R u+w $out

      # 1) ikon & teks bar = putih opaque
      sed -i 's/darkTextPrimary: Qt.rgba(0.92, 0.92, 0.96, 0.90)/darkTextPrimary: "#ffffff"/' $out/lib/Colors.qml
      sed -i 's/lightTextPrimary: Qt.rgba(0.92, 0.92, 0.96, 0.90)/lightTextPrimary: "#ffffff"/' $out/lib/Colors.qml

      # 2) fade idle 0.6 -> 1.0 di SEMUA komponen (wifi, bluetooth, notif, tray, idle, airplane, brightness, volume)
      find $out -name '*.qml' -exec sed -i 's/containsMouse ? 1.0 : 0.6/containsMouse ? 1.0 : 1.0/g' {} +
      sed -i 's/root.hovered ? 1.0 : 0.6/root.hovered ? 1.0 : 1.0/' $out/components/ui/ImeIndicator.qml
      sed -i 's/normalOpacity: 0.6/normalOpacity: 1.0/' $out/components/common/IconButton.qml
      sed -i 's/trayMouse.containsMouse ? 1.0 : 0.75/trayMouse.containsMouse ? 1.0 : 1.0/' $out/components/ui/Tray.qml

      # 3) font global -> JetBrains Mono (bar, menu, panel, semua teks QML)
      find $out -name '*.qml' -exec sed -i 's/M PLUS 1 Code/JetBrains Mono/g; s/M PLUS 2/JetBrains Mono/g' {} +

      # gagal dengan jelas kalau upstream ganti string-nya
      grep -q 'darkTextPrimary: "#ffffff"' $out/lib/Colors.qml || { echo "PATCH GAGAL: Colors.qml"; exit 1; }
      grep -rq 'containsMouse ? 1.0 : 0.6' $out && { echo "PATCH GAGAL: masih ada opacity 0.6"; exit 1; }
    '';
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        mugen-shell.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          programs.mugen-shell.enable = true;

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.shrky = {
            imports = [
              ./home.nix
              mugen-shell.homeManagerModules.default
            ];
            programs.mugen-shell = {
              enable = true;
              includeSystemDeps = false;
              quickshellExecutable = "/run/current-system/sw/bin/quickshell";
              ai.enable = true;
              package = mugen-shell-bright;
            };
          };
        }
      ];
    };
  };
}
