# Konfigurasi user (Home Manager).
{ username, ... }:

{
  imports = [
    ./packages.nix
    ./git.nix
    ./shell.nix
    ./kitty.nix
    ./macshell.nix
    ./hyprland.nix
    ./vesktop.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
  };
}
