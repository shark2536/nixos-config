{ config, pkgs, ... }:

{
  home.username = "shrky";
  home.homeDirectory = "/home/shrky";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    htop
    btop
    ripgrep
    fd
    cowsay
  ];

  programs.git = {
    enable = true;
    settings.user = {
      name = "shark2536";
      email = "67108091+shark2536@users.noreply.github.com";
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-config";
      nrt = "sudo nixos-rebuild test --flake ~/nixos-config";
    };
  };
}
