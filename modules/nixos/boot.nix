# Bootloader GRUB (UEFI) + deteksi OS lain (dual boot).
{
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      configurationLimit = 10; # /boot terpisah, batasi jumlah generasi biar tidak penuh
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };

  boot.tmp.cleanOnBoot = true;
}
