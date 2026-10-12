# Konfigurasi user (Home Manager).
{ username, ... }:

{
  imports = [
    ./packages.nix
    ./git.nix
    ./shell.nix
    ./kitty.nix
    ./mugen-shell.nix
    ./emoji-picker.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
  };
}
