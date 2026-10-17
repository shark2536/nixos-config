{ pkgs, ... }:

{
  # Pastikan GPG Agent aktif dan mengenali pinentry
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses; # Bisa pakai pkgs.pinentry-qt jika pakai KDE Plasma
  };

  # Tambahkan paket ke sistem
  environment.systemPackages = with pkgs; [
    gnupg
    pinentry-curses
  ];
}
