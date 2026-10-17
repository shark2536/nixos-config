# Sisi sistem untuk MacShell (bar + Dock gaya macOS, Quickshell).
# Sisi user (copy config + hyprland.lua) ada di home/macshell.nix & home/hyprland.nix.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    quickshell # wajib: runtime shell-nya
    qt6Packages.qtshadertools # wajib: `qsb`, kompilasi shader Liquid Glass saat pertama jalan
    qt6Packages.qtsvg # ikon SVG aplikasi
    qt6Packages.qtwayland
    hyprlock # stack PAM untuk MacLock (lock screen)

    # opsional — yang absen hanya menonaktifkan fitur terkait:
    grim # screenshot
    wl-clipboard # clipboard + copy screenshot
    cliphist # riwayat clipboard di Spotlight
    libnotify # notify-send
    wf-recorder # screen recording
    hyprpicker # color picker
    hyprsunset # night shift
    brightnessctl # brightness
    inotify-tools # pantau trash
    swww # wallpaper (MacShell membaca `swww query`)
    papirus-icon-theme # ikon aplikasi untuk Dock & Spotlight
    fastfetch # "About This Linux"
    xdg-utils # xdg-open
  ];

  # MacLock memeriksa password lewat PAM hyprlock.
  security.pam.services.hyprlock = { };

  # Ikon tema untuk aplikasi Qt (Dock & Spotlight mengambil ikon dari sini).
  environment.sessionVariables.QS_ICON_THEME = "Papirus-Dark";
}
