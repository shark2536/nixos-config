# Pengaturan Nix itu sendiri: flakes, pembersihan otomatis, helper `nh`.
{ username, ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
    warn-dirty = false;
  };

  # Hemat disk: deduplikasi file di /nix/store tiap minggu.
  nix.optimise.automatic = true;

  # `nh` = wrapper nixos-rebuild yang lebih enak (ada diff + progress) sekaligus pembersih generasi lama.
  programs.nh = {
    enable = true;
    flake = "/home/${username}/nixos-config";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 14d --keep 5";
    };
  };
}
