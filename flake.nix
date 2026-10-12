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
      # Pakai satu home-manager yang sama, jangan download dua kali.
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "shrky";
      pkgs = nixpkgs.legacyPackages.${system};

      # Daftar emoji untuk emoji picker (lihat pkgs/emoji-data.nix).
      emoji-data = pkgs.callPackage ./pkgs/emoji-data.nix { };

      # Mugen-shell dengan patch tampilan kamu + lock screen + emoji picker (lihat pkgs/mugen-shell-bright.nix).
      mugen-shell-bright = pkgs.callPackage ./pkgs/mugen-shell-bright.nix {
        mugen-shell = inputs.mugen-shell;
        inherit emoji-data;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          ./hosts/nixos
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit inputs username mugen-shell-bright; };
              users.${username} = import ./home;
            };
          }
        ];
      };

      # `nix fmt` untuk merapikan semua file .nix
      formatter.${system} = pkgs.nixfmt;
    };
}
