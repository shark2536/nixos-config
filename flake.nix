{
  description = "NixOS config shrky";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # MacShell: menu bar + Dock gaya macOS untuk Hyprland (Quickshell).
    # Repo ini tidak punya flake.nix, jadi di-fetch polos (flake = false)
    # lalu di-copy ke ~/.config/quickshell lewat home/macshell.nix.
    macshell = {
      url = "github:0-ss/MacShell";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "shrky";
      pkgs = nixpkgs.legacyPackages.${system};
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
              extraSpecialArgs = { inherit inputs username; };
              users.${username} = import ./home;
            };
          }
        ];
      };

      # `nix fmt` untuk merapikan semua file .nix
      formatter.${system} = pkgs.nixfmt;
    };
}
