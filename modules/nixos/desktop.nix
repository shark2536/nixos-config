# Login manager + desktop. Hyprland = utama, Plasma 6 = cadangan (pilih di layar login SDDM).
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  programs.hyprland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Dibutuhkan aplikasi GTK untuk menyimpan/membaca pengaturan tema.
  programs.dconf.enable = true;
}
