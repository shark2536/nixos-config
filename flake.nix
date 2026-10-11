{
  description = "NixOS config shrky";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mugen-shell = {
      url = "github:tmy7533018/mugen-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, mugen-shell, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        mugen-shell.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          # Lapisan sistem
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
              includeSystemDeps = false;   # dependensi sudah ada di path sistem
              quickshellExecutable = "/run/current-system/sw/bin/quickshell";
              ai.enable = false;           # matikan layanan AI (Yura) dulu, bisa dinyalakan nanti
            };
          };
        }
      ];
    };
  };
}
