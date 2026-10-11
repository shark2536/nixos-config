# Dasar sistem: jaringan, waktu, bahasa, keyboard, layanan umum.
{
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Swap di RAM (terkompresi). Sebelumnya sistem sama sekali tanpa swap.
  zramSwap.enable = true;

  # SSD/NVMe & btrfs
  services.fstrim.enable = true;
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  services.printing.enable = true;
}
