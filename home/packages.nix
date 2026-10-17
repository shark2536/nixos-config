# Aplikasi & tools milik user.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # monitor & CLI
    htop
    btop
    ripgrep
    fd
    bat
    eza
    tree
    unzip
    fastfetch
    cowsay

    # Nix
    nixfmt

    # aplikasi
    kitty # terminal default MacShell
    spotify
    kdePackages.kate
    godot
  ];
}
