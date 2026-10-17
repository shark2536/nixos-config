# Paket tingkat sistem (tersedia untuk semua user, termasuk root).
# Aplikasi pribadi ada di home/packages.nix.
{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git # wajib ada di sistem: flake butuh git untuk membaca repo config
    pciutils
    wtype # dipakai emoji picker untuk mengetik emoji langsung ke aplikasi
    fcitx5
    hunspellDicts.id_ID
  ];
}
